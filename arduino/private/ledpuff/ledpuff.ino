#include <Wire.h> // For I2C communication

//This is the I2C Address of the MCP4725, by default (A0 pulled to GND).
//Please note that this breakout is for the MCP4725A0. 
#define MCP4725_ADDR 0x60   // DAC
#define MAXDACUNIT 4095       // 2^12-1 (ie 12 bits)
#define MINDACUNIT 0
// For converstion from laser power to DAC units
// For laser 11140001, Rig 1
//#define LASERSLOPE 27
//#define LASEROFFSET 2400
// For laser 11140002, Rig 2
//#define LASERSLOPE 36
//#define LASEROFFSET 2100
// For laser 11140002, Rig 3
//#define LASERSLOPE 30
//#define LASEROFFSET 2500
// For laser 11140002, Rig 4
#define LASERSLOPE 36
#define LASEROFFSET 2100
//For devices with A0 pulled HIGH, use 0x61

/*
  Conditioning
  to regulate camera, CS (LED, tone, whisker puff, ...), US.
 */

// Outputs
int greenled = 7; 
int camera = 8;
int led = 9;
int whisker = 10;
int tonech = 11;
int laser = 12;
int puff = 13;

// Used internally to select channels for CS/US
int csout = 0;  // Not used yet
int usout = 0;  // Used for 2nd order conditioning to use "US" as CS2

// Task variables (time in ms, freq in hz)
int campretime = 200;
int camposttime = 800;
int csdur = 500;
int csch = 1;   // default to LED
int usch = 3;   // default to ipsi corneal puff
int ISI = 200;
int usdur = 20;
int residual;
int tonefreq5 = 10000;

// Added as temporary fix to allow laser stim during trial
int laserdelay = 0; // delay from CS onset until laser onset
int laserdur = 0; // duration of laser pulse
int laserpower = 0; // in the future we should use float

unsigned long trialtime = 0; // For keeping track of elapsed time during trial

// the setup routine runs once when you press reset:
void setup() {
  // initialize the digital pin as an output.
  pinMode(camera, OUTPUT);
  pinMode(led, OUTPUT);
  pinMode(puff, OUTPUT);
  pinMode(whisker, OUTPUT);
  pinMode(tonech, OUTPUT);
  pinMode(greenled, OUTPUT); 
  pinMode(laser, OUTPUT); 

  // Default all output pins to LOW - for some reason they were floating high on the Due before I (Shane) added this
  digitalWrite(camera, LOW);
  digitalWrite(led, LOW);
  digitalWrite(puff, LOW);
  digitalWrite(whisker, LOW);
  digitalWrite(tonech, LOW);
  digitalWrite(greenled, LOW);
  digitalWrite(laser, LOW);

  Serial.begin(115200);
  Wire.begin();

  DACWrite(0);
}

// the loop routine runs over and over again forever:
void loop() {
  // Consider using attachInterrupt() to allow better realtime control of starting and stopping, etc.

  checkVars();
  if (Serial.available() > 0) {
    if (Serial.peek() == 1) { // This is the header for triggering; difference from variable communication is that only one byte is sent telling to trigger
      Serial.read();  // Clear the value from the buffer
      Triggered();
    }
  }
  delay(1);
}


// Check to see if Matlab is trying to send updated variables
void checkVars() {
  int header;
  int value;
  // Matlab sends data in 3 byte packets: first byte is header telling which variable to update,
  // next two bytes are the new variable data as 16 bit int
  // Header is coded numerically such that 1=trigger, 2=continuous, 3=CS channel, 4=CS dur,
  // 0 is reserved for some future function, possibly as a bailout (i.e. stop reading from buffer).
  while (Serial.available() > 2) {
    header = Serial.read();
    value = Serial.read() | Serial.read() << 8;

    if (header == 0) {
      break;
    }

    switch (header) {
      case 3:
        campretime = value;
        break;
      case 4:
        csch = value;
        break;
      case 5:
        csdur = value;
        break;
      case 6:
        usdur = value;
        break;
      case 7:
        ISI = value;
        break;
      case 8:
        tonefreq5 = value;
        break;
      case 9:
        camposttime = value;
        break;
      case 10:
        usch = value;
        break;
      case 11:
        laserdelay = value;
        break;
      case 12:
        laserdur = value;
        break;
      case 13:
        laserpower = value;
        break;
    }
    delay(4); // Delay enough to allow next 3 bytes into buffer (24 bits/9600 bps = 2.5 ms, so double it for safety).
  }
}


// --- function executed to start a trial ----
void Triggered() {
  unsigned long now;
  // triggering camera
  digitalWrite(camera, HIGH);  // Camera will collect the number of frames that we specify while TTL is high

  // NOTE: I removed the single short pulse because camera is now configured for "TTL High" instead of "Rising-Edge"
  //  delay(1);
  //  digitalWrite(camera, LOW);
  //  residual=campretime-1;
  residual = campretime;
  if (residual > 0) {
    delay(residual);          // wait
  }

  // starting a trial
  trialtime = millis();

  if (csdur <= ISI) {
    doTrace();
  }
  else { doDelay(); }

  now = millis();
  if (now - trialtime < camposttime) {
    //delay(int(now - trialtime));
    delay(camposttime - int(now - trialtime));
  }

  // Camera will only collect the number of frames that we specify so we only have to reset TTL
  // to low before starting the next trial. The hitch is that if we set it low too early we won't
  // collect all of the frames that we asked for and the camera will get stuck; hence the extra delay.
  delay(10); // Delay a little while longer just to be safe - so the camera doesn't get stuck with more frames to acquire
  digitalWrite(camera, LOW);
}

/* We one of two functions depending on whether we're doing something like "trace"
or something like "delay" conditioning
*/

void doDelay() {

  csON();

  if (laserdur > 0) {
    delay(laserdelay);
    laserOn();
    delay(ISI-laserdelay);
  }
  else { delay(ISI); }

  usON();
  
  if (csdur < (ISI+usdur)) {
   delay(csdur-ISI);
   csOFF();
   residual = usdur - (csdur-ISI);
  }
  else {
    residual = usdur;
  }   
  
  delay(residual);                  // wait for remainder of us (or all if cs is longer)
  
  usOFF();

  if (laserdur > 0) {
    residual = (laserdelay + laserdur) - ISI - usdur;
    if (residual > 0) {
      delay(residual);
      residual = csdur - (laserdelay + laserdur);
    }
    laserOff();
  }
  else {
    residual = csdur - ISI - usdur;
  }

  if (residual > 0) {
    delay(residual);          // wait for whatever additional time cs is on
  }

  csOFF();

}

void doTrace() {

  csON(); 
  
  delay(csdur);
  
  csOFF();
  
  residual = ISI-csdur;
  
  if (residual > 0) {
    delay(residual);    // residual is trace period
  }

  usON();
  delay(usdur);                  // wait for us
  usOFF();  
  
}

void doDelayWithLaser() {
  csON();
  
  // We have to figure out what the order of state transitions should be
  // This seems better implemented as a DAG (directed acyclic graph), where
  // each node is a state transition and the edges are delays. 
  // Can we do this relatively easily in Arduino? We first need to sort based on
  // delays from trial onset, then make a priority queue for each state transition and
  // it's associated residual delay. 

  delay(ISI);

  usON();
  
  if (csdur < (ISI+usdur)) {
   delay(csdur-ISI);
   csOFF();
   residual = usdur - (csdur-ISI);
  }
  else {
    residual = usdur;
  }   
  
  delay(residual);                  // wait for remainder of us (or all if cs is longer)
  
  usOFF();

  residual = csdur - ISI - usdur;
  if (residual > 0) {
    delay(residual);          // wait for whatever additional time cs is on
  }

  csOFF();

}

void csON() {
 if (csdur > 0) {
    switch (csch) {
      case 1:
        digitalWrite(led, HIGH);   // turn the LED on (HIGH is the voltage level)
        break;
      case 2:
        digitalWrite(whisker, HIGH);   // turn the LED on (HIGH is the voltage level)
        break;
      case 5:
        tone(tonech, tonefreq5, csdur);   
        break;
      case 6:
        tone(tonech, tonefreq5, csdur);   
        break;
      case  7:
        digitalWrite(greenled, HIGH); // turn the green LED on (HIGH is the voltage level) 
        break; 
    }
  } 
}


void csOFF() {
     if (csdur > 0) {
    switch (csch) {
      case 1:
        digitalWrite(led, LOW);   // turn the LED on (HIGH is the voltage level)
        break;
      case 2:
        digitalWrite(whisker, LOW);   // turn the LED on (HIGH is the voltage level)
        break;
      case 7:
        digitalWrite(greenled, LOW); //  turn the green LED off (LOW is the voltage level) 
        break; 
    }
  }
}

void usON() {
    if (usdur > 0) {

    switch (usch) {
      case 1:
        usout = led;
        break;
      case 2:
        usout = whisker;
        break;
      case 3:
        usout = puff;
        break;
      case 7:
        usout = greenled;
        break;
      case 5:      // Tone is a special case that we have to handle differently 
        tone(tonech, tonefreq5, usdur);
        usout = 0;
        break;
      case 6:      // Tone is a special case that we have to handle differently 
        tone(tonech, tonefreq5, usdur);
        usout = 0;
        break;
      default:
        usout = 0;
    }
  }

  if (usout > 0) {
  digitalWrite(usout, HIGH);   // turn the PUFF on (HIGH is the voltage level)
  }
}

void usOFF() { 
  if (usout > 0) {
  digitalWrite(usout, LOW);    // turn the PUFF off (HIGH is the voltage level)
  }
}

void laserOn(){
  // digitalWrite(laser, HIGH);
  DACWrite(powerToDACUnits(laserpower));
}


void laserOff() {
  // digitalWrite(laser, LOW);
  DACWrite(MINDACUNIT);
}

void DACWrite(int DACvalue) {
 
  Wire.beginTransmission(MCP4725_ADDR);
  Wire.write(64);                     // cmd to update the DAC
  Wire.write(DACvalue >> 4);        // the 8 most significant bits...
  Wire.write((DACvalue & 15) << 4); // the 4 least significant bits...
  Wire.endTransmission(); 
  
}

int powerToDACUnits(int power) {

  int DACUnits = power * LASERSLOPE + LASEROFFSET;

  if (power == 0) {return 0;}

  if (DACUnits < MAXDACUNIT) {return DACUnits;}
  else {return MAXDACUNIT;}

}

/*
 Tone generator for Arduino Due
 v1  use timer, and toggle any digital pin in ISR
   funky duration from arduino version
   TODO use FindMckDivisor?
   timer selected will preclude using associated pins for PWM etc.
    could also do timer/pwm hardware toggle where caller controls duration
*/


// timers TC0 TC1 TC2   channels 0-2 ids 0-2  3-5  6-8     AB 0 1
// use TC1 channel 0
#define TONE_TIMER TC1
#define TONE_CHNL 0
#define TONE_IRQ TC3_IRQn

// TIMER_CLOCK4   84MHz/128 with 16 bit counter give 10 Hz to 656KHz
//  piano 27Hz to 4KHz

static uint8_t pinEnabled[PINS_COUNT];
static uint8_t TCChanEnabled = 0;
static boolean pin_state = false ;
static Tc *chTC = TONE_TIMER;
static uint32_t chNo = TONE_CHNL;

volatile static int32_t toggle_count;
static uint32_t tone_pin;

// frequency (in hertz) and duration (in milliseconds).

void tone(uint32_t ulPin, uint32_t frequency, int32_t duration)
{
  const uint32_t rc = VARIANT_MCK / 256 / frequency;
  tone_pin = ulPin;
  toggle_count = 0;  // strange  wipe out previous duration
  if (duration > 0 ) toggle_count = 2 * frequency * duration / 1000;
  else toggle_count = -1;

  if (!TCChanEnabled) {
    pmc_set_writeprotect(false);
    pmc_enable_periph_clk((uint32_t)TONE_IRQ);
    TC_Configure(chTC, chNo,
                 TC_CMR_TCCLKS_TIMER_CLOCK4 |
                 TC_CMR_WAVE |         // Waveform mode
                 TC_CMR_WAVSEL_UP_RC ); // Counter running up and reset when equals to RC

    chTC->TC_CHANNEL[chNo].TC_IER = TC_IER_CPCS; // RC compare interrupt
    chTC->TC_CHANNEL[chNo].TC_IDR = ~TC_IER_CPCS;
    NVIC_EnableIRQ(TONE_IRQ);
    TCChanEnabled = 1;
  }
  if (!pinEnabled[ulPin]) {
    pinMode(ulPin, OUTPUT);
    pinEnabled[ulPin] = 1;
  }
  TC_Stop(chTC, chNo);
  TC_SetRC(chTC, chNo, rc);    // set frequency
  TC_Start(chTC, chNo);
}

void noTone(uint32_t ulPin)
{
  TC_Stop(chTC, chNo);  // stop timer
  digitalWrite(ulPin, LOW); // no signal on pin
}

// timer ISR  TC1 ch 0
void TC3_Handler ( void ) {
  TC_GetStatus(TC1, 0);
  if (toggle_count != 0) {
    // toggle pin  TODO  better
    digitalWrite(tone_pin, pin_state = !pin_state);
    if (toggle_count > 0) toggle_count--;
  } else {
    noTone(tone_pin);
  }
}



