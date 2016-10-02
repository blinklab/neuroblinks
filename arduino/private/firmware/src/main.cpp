// TODO: Put Arduino to sleep when not running neuroblinks (e.g. pmc_enable_sleepmode())
// TODO: Deal with overflow of millisecond/microsecond timers
// TODO: Non-blocking Serial IO and better serial communication generally (consider Serial.SerialEvent())
//       For instance https://github.com/siggiorn/arduino-buffered-serial

#include "main.hpp"
#include <Encoder.h>
#include <tone.hpp>

// Stimulus channels (as defined in Matlab code)
const int ch_led = 1;
const int ch_puffer_other = 2;
const int ch_puffer_eye = 3;
const int ch_tone = 5;
const int ch_brightled = 7;

// Outputs
const int pin_ss = 4;  // slave select Pin. need one for each external chip you are going to control.
const int pin_brightled = 7;
const int pin_camera = 8;
const int pin_led = 9;
const int pin_whisker = 10;
const int pin_tone = 11;
const int pin_laser = 12;
const int pin_eye_puff = 13;

// Index into array indicates stimulus number as specified in Matlab, value at that index is corresponding pin number on Arduino
// Index zero should always have zero value because there is no stimulus 0
// Other zeros can be filled in with other values as needed
const int stim2pinMapping[10] {
    0,
    pin_led,
    pin_whisker,
    pin_eye_puff,
    0,
    pin_tone,
    0,
    pin_brightled,
    0,
    0
};

// Task variables (time in ms, freq in hz) - can be updated from Matlab
// All param_* variables must be 16-bit ints or else they will screw up Serial communication
//    and get mangled
int param_campretime = 200;
int param_camposttime = 800;
int param_csdur = 500;
int param_ISI = 200;
int param_usdur = 20;
int param_csch = ch_led;   // default to LED
int param_usch = ch_puffer_eye;   // default to ipsi corneal puff
int param_tonefreq = 10000;
int param_csintensity = 256; // default to max intensity

// For laser stim during trials, time values in ms
int param_laserdelay = 0; // delay from CS onset until laser onset
int param_laserdur = 0; // duration of laser pulse
int param_laserperiod = 0; // period of laser pulse
int param_lasernumpulses = 1; // number of laser pulses in train
int param_laserpower = 0; // In DAC units (i.e., 0 --> GND, 4095 --> Vs)
int param_lasergain = 1;
int param_laseroffset = 0;

int param_encoderperiod = 5; // in ms
int param_encodernumreadings = (param_campretime + param_camposttime) / param_encoderperiod; // number of readings to take during trial

// Codes for sending arrays to Matlab - consider enum type cast to byte
const byte ENCODER_L = 100;
const byte TIME_L = 101;
// For converting longs to bytes
const uint32_t bit_patterns[4] = { 0x000000ff, 0x0000ff00, 0x00ff0000, 0xff000000 };

bool RUNNING = false;

// Default constructors for StateMachine objects
// It's probably more flexible if we create an array of StateMachine objects that we can iterate through in main loop but for now this will work
//    and seems easier to comprehend
Stimulus camera(0, param_campretime + param_camposttime, digitalOn, digitalOff, pin_camera);
Stimulus CS(param_campretime, param_csdur, digitalOn, digitalOff, stim2pinMapping[param_csch]);
Stimulus US(param_campretime + param_ISI, param_usdur, digitalOn, digitalOff, stim2pinMapping[param_usch]);
StimulusRepeating laser(param_campretime + param_laserdelay, param_laserdur, laserOn, laserOff, 0, param_laserperiod, param_lasernumpulses);

SensorRepeating enc(0, takeEncoderReading, param_encoderperiod, param_encodernumreadings);

Encoder cylEnc(2, 3); // pins used should have interrupts, e.g. 2 and 3

// The setup routine runs once when you press reset or get reset from Serial port
void setup() {
  // Initialize the digital pin as an output.
  pinMode(pin_camera, OUTPUT);
  pinMode(pin_led, OUTPUT);
  pinMode(pin_eye_puff, OUTPUT);
  pinMode(pin_whisker, OUTPUT);
  pinMode(pin_tone, OUTPUT);
  pinMode(pin_brightled, OUTPUT);
  pinMode(pin_laser, OUTPUT);
  pinMode(pin_ss, OUTPUT);

  // Default all output pins to LOW - for some reason they were floating high on the Due before I (Shane) added this
  digitalWrite(pin_camera, LOW);
  digitalWrite(pin_led, LOW);
  digitalWrite(pin_eye_puff, LOW);
  digitalWrite(pin_whisker, LOW);
  digitalWrite(pin_tone, LOW);
  digitalWrite(pin_brightled, LOW);
  digitalWrite(pin_laser, LOW);

  // set your ssPin to LOW too. when you have more external chips to control, you will have to be more careful about this step (ssPin LOW means the chip will respond to SPI commands)
  digitalWrite(pin_ss, LOW);
  SPI.begin();
  SPI.setBitOrder(MSBFIRST);  // if you are using the MCP4131

  Serial.begin(115200);
  Wire.begin();

  DACWrite(0);
}

// The loop routine runs over and over again forever
// In this loop we have our StateMachines check their states and update as necessary
// The StateMachines handle their own timing
// It's critical that this loop runs fast (< 1 ms period) so don't put anything in here that takes time to execute
// if a trial is running (e.g. "blocking" serial port access should only happen when trial isn't RUNNING)
void loop() {

  if (RUNNING) {

      // We explicitly check for zero durations to prevent stimuli from flashing on briefly when update() called and duration is zero
      if (param_csdur > 0) { CS.update(); }
      if (param_usdur > 0) { US.update(); }
      if (param_laserdur > 0) { laser.update(); }

      camera.update();

      enc.update();

      if (camera.checkState()==camera.OFF) { endOfTrial(); }

  }

  else {
      checkVars();
      if (Serial.available() > 0) {
          if (Serial.peek() == 1) { // This is the header for triggering; difference from variable communication is that only one byte is sent telling to trigger
              Serial.read();  // Clear the value from the buffer
              startTrial();
          }
          else if (Serial.peek() ==2) {
            Serial.read();  // Clear the value from the buffer
            // We should eventually generalize this part for sending and receiving settings/data with Matlab
            sendEncoderData();
            enc.reset();
          }
      }
  }

}

// Check to see if Matlab is trying to send updated variables
// (should we send specific code to indicate that we are sending variables?)
void checkVars() {
  int header;
  int value;
  // Matlab sends data in 3 byte packets: first byte is header telling which variable to update,
  // next two bytes are the new variable data as 16 bit int (can only send 16 bit ints for now)
  // Header is coded numerically (0, 1, and 2 are reserved for special functions so don't use them to code variable identities)
  while (Serial.available() > 2) {
    header = Serial.read();
    value = Serial.read() | Serial.read() << 8;

    if (header == 0) {
      flushReceiveBuffer();     // A way to bail out and start over if the Arduino stops responding due to problem parsing Serial inputs
      break;
    }

    // If you add a new case don't forget to put a break statement after it; c-style switches run through
    switch (header) {
      case 3:
        param_campretime = value;
        break;
      case 4:
        param_csch = value;
        break;
      case 5:
        param_csdur = value;
        break;
      case 6:
        param_usdur = value;
        break;
      case 7:
        param_ISI = value;
        break;
      case 8:
        param_tonefreq = value;
        break;
      case 9:
        param_camposttime = value;
        break;
      case 10:
        param_usch = value;
        break;
      case 11:
        param_laserdelay = value;
        break;
      case 12:
        param_laserdur = value;
        break;
      case 13:
        param_laserpower = value;
        break;
      case 14:
        param_csintensity = value;
        setDiPoValue(param_csintensity);
        break;
      case 15:
        param_laserperiod = value;
        break;
      case 16:
        param_lasernumpulses = value;
        break;
    }
    // We might be able to remove this delay if Matlab sends the parameters fast enough to buffer
    delay(1); // Delay enough to allow next 3 bytes into buffer (24 bits/115200 bps = ~200 us, so delay 1 ms to be safe).
  }
}

// Update the instantiated StateMachines here with any new values that have been sent from Matlab
void configureTrial() {

    camera.setDuration(param_campretime + param_camposttime);

    CS.setDuration(param_csdur);
    CS.setFunctionArg(stim2pinMapping[param_csch]);

    US.setDelay(param_campretime + param_ISI);
    US.setDuration(param_usdur);
    US.setFunctionArg(stim2pinMapping[param_usch]);

    laser.setDelay(param_campretime + param_laserdelay);
    laser.setDuration(param_laserdur);
    laser.setPeriod(param_laserperiod);
    laser.setNumRepeats(param_lasernumpulses);

}

// Called by main loop when Arduino receives trigger from Matlab
void startTrial() {

    configureTrial();

    RUNNING = true;

    // Once StateMachines have been started the delay clock is ticking so don't put anything else below the call to start()
    // We want to return to the main loop ASAP after StateMachines have started
    // Each start() method only contains one function call to get current time and two assignment operations so should return quickly
    // The duration of the trial is determined by the camera parameters (delay, duration) -- all timing is relative to it
    camera.start();

    enc.start();

    // duration of zero means it's not supposed to run on this trial so don't bother to start it
    if (param_csdur > 0) { CS.start(); }
    if (param_usdur > 0) { US.start(); }
    if (param_laserdur > 0) { laser.start(); }

}

// Called by main loop when camera stops
void endOfTrial() {

    RUNNING = false;

    // These should already be stopped if we timed things well but we'll do it again just to be safe
    CS.stop();
    US.stop();
    laser.stop();
    enc.stop();
    camera.stop(); // Should already be stopped if this function was called

}

// Make sure this code executes fast (< 1 ms) so it doesn't screw up the timing for everything else
void DACWrite(int DACvalue) {

    Wire.beginTransmission(MCP4725_ADDR);
    Wire.write(64);                     // cmd to update the DAC
    Wire.write(DACvalue >> 4);        // the 8 most significant bits...
    Wire.write((DACvalue & 15) << 4); // the 4 least significant bits...
    Wire.endTransmission();

}

int powerToDACUnits(int power) {

    int DACUnits = power * param_lasergain + param_laseroffset;

    if (DACUnits < MAXDACUNIT) {return DACUnits;}
    else {return MAXDACUNIT;}

}

// for working with the MCP4131 digital potentiometer
void setDiPoValue(int value)
{
    //digitalWrite(ssPin, LOW); // use this step to select your DiPo if you are working with multiple external chips through SPI
    SPI.transfer(0);
    SPI.transfer(value);
    //digitalWrite(ssPin, HIGH); // use this step to deselect your DiPo if you are working with multiple external chips through SPI
}

// Tone is a special case of digitalWrite because it uses a timer to cycle at requested frequency
void digitalOn(int pin) {
    if (pin == pin_tone) {
        toneOn(pin);
    }
    else {
        digitalWrite(pin, HIGH);
    }
}

void digitalOff(int pin) {
    if (pin == pin_tone) {
        toneOff(pin);
    }
    else {
        digitalWrite(pin, LOW);
    }
}

void toneOn(int pin) {
    tone(pin, param_tonefreq, 0);
};

void toneOff(int pin) {
    noTone(pin);
};

void laserOn(int dummy) { // Function signature requires int but we don't need it so call it "dummy"
    DACWrite(powerToDACUnits(param_laserpower));
}

void laserOff(int dummy) { // Function signature requires int but we don't need it so call it "dummy"
    DACWrite(0);
}

// We call by reference so we can update the local variables in "reading_function" of StateMachine object
void takeEncoderReading(timems_t &time, int32_t &reading) {

    time = millis();
    // reading = cylEnc.read();
    reading = 5000-random(10000);  // for testing

}

void sendEncoderData() {

    // Consider using Serial.availableForWrite() if the code below is blocking

    Serial.write(ENCODER_L);
    // Maybe also send number of values so Matlab knows how many to expect (will have to be 2 bytes though)?
    for (int i=0; i<param_encodernumreadings; i++) {
        writeLong(enc.getReading(i));
    }

    Serial.write(TIME_L);
    // Maybe also send number of values so Matlab knows how many to expect (will have to be 2 bytes though)?
    for (int i=0; i<param_encodernumreadings; i++) {
        writeLong(enc.getTime(i));
    }
}

// We have to send bytes over the serial port, so break the 32-bit integer into 4 bytes by ANDing only the byte we want
// and shifting that byte into the first 8 bits
// Unsigned longs
void writeLong(uint32_t long_value) {
    for (int i=0; i<4; i++) {
        // Can we do this instead: (byte)(long_value >> 24) [replacing 24 with appropriate shift]?
        // Cast to byte will truncate to first 8 bits as side effect
        byte val = ( long_value & bit_patterns[i] ) >> 8*i;
        Serial.write(val);
    }
}

// Overloaded for signed longs
void writeLong(int32_t long_value) {
    for (int i=0; i<4; i++) {
        byte val = ( long_value & bit_patterns[i] ) >> 8*i;
        Serial.write(val);
    }
}

void flushReceiveBuffer() {
    while(Serial.available()) {
        Serial.read();
    }
}
