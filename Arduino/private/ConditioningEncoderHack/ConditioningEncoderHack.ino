#include <DueTimer.h>
#include <Encoder.h>

const int MAXDATALENGTH = 10000;
const int NUMTIMERS = 6;

// Pin mappings
const int GREENLED = 7;
const int CAMERA = 8;
const int LED = 9;
const int WHISKER = 10;
const int TONE = 11;
const int LASER = 12;
const int PUFF = 13;

// Codes for variables
// Arrays
const byte ENCODER_L = 100;
const byte TIME_L = 101;
const byte DELAYS_L = 110;
const byte DURATIONS_L = 111;
const byte STIM_L = 112;
// Single vars
const byte TRIALDURATION_U = 200;
const byte TONEFREQ_U = 201;

// All int types on Due are 32 bits
unsigned int trial_duration = 1000; // in ms
unsigned int sample_interval = 5; // in ms: 200 Hz to match camera FPS
unsigned int num_data_pts = trial_duration / sample_interval;
unsigned int sample_counter = 0; // updated every time a sample is taken in callback

unsigned int tone_freq = 10000;

long encoder_counts[MAXDATALENGTH];     // Encoder counts since starting program
long sample_times[MAXDATALENGTH]; // Time since trial started, in ms. (using signed int so it's same DT as encoder_counts)

// One value for each timer (we allow 6 so we have 3 for other things)
// In the final version these should all be set to 0 or -1 by default
// To delay 0 we might need to actually delay 1 us.
long delays[NUMTIMERS] = {200000, 300000, 400000, 0, 0, 0};
long durations[NUMTIMERS] = {300000, 100000, 20000, 0, 0, 0};
long delays_actual[NUMTIMERS];
long durations_actual[NUMTIMERS];

long stim[NUMTIMERS] = {GREENLED, LASER, PUFF, 0, 0, 0};

// Timer6 is reserved for sampling data values
// Can't use Timer4 because Due tone function uses it
DueTimer *timer_list[NUMTIMERS] = {&Timer0, &Timer1, &Timer2,
                          &Timer3, &Timer7, &Timer5};

Encoder cylEnc(2, 3); // pins used should have interrupts, e.g. 2 and 3

unsigned long start_ms=millis();
boolean RUNNING = false;

void delay0() {
  // Delays set amount of time before triggering
  timer_list[0]->stop();
  stimOn(0);
  // Now set duration
  timer_list[0]->attachInterrupt(duration0);
  timer_list[0]->start(durations[0]);

}

void delay1() {
  // Delays set amount of time before triggering
  timer_list[1]->stop();
  stimOn(1);
  // Now set duration
  timer_list[1]->attachInterrupt(duration1);
  timer_list[1]->start(durations[1]);

}

void delay2() {
  // Delays set amount of time before triggering
  timer_list[2]->stop();
  stimOn(2);
  // Now set duration
  timer_list[2]->attachInterrupt(duration2);
  timer_list[2]->start(durations[2]);

}

void delay3() {
  // Delays set amount of time before triggering
  timer_list[3]->stop();
  stimOn(3);
  // Now set duration
  timer_list[3]->attachInterrupt(duration3);
  timer_list[3]->start(durations[3]);

}

void delay4() {
  // Delays set amount of time before triggering
  timer_list[4]->stop();
  stimOn(4);
  // Now set duration
  timer_list[4]->attachInterrupt(duration4);
  timer_list[4]->start(durations[4]);

}

void delay5() {
  // Delays set amount of time before triggering
  timer_list[5]->stop();
  stimOn(5);
  // Now set duration
  timer_list[5]->attachInterrupt(duration5);
  timer_list[5]->start(durations[5]);

}

void duration0() {
  timer_list[0]->stop().detachInterrupt();
  stimOff(0);
}

void duration1() {
  timer_list[1]->stop().detachInterrupt();
  stimOff(1);
}

void duration2() {
  timer_list[2]->stop().detachInterrupt();
  stimOff(2);
}

void duration3() {
  timer_list[3]->stop().detachInterrupt();
  stimOff(3);
}

void duration4() {
  timer_list[4]->stop().detachInterrupt();
  stimOff(4);
}

void duration5() {
  timer_list[5]->stop().detachInterrupt();
  stimOff(5);
}


void stimOn(int num) {
   switch (stim[num]) {
     case GREENLED:
       digitalWrite(stim[num],HIGH);
       break;
     case LED:
       digitalWrite(stim[num],HIGH);
       break;
     case WHISKER:
       digitalWrite(stim[num],HIGH);
       break;
     case PUFF:
       digitalWrite(stim[num],HIGH);
       break;
     case TONE:
//       tone(stim[num], tone_freq, 0);
       break;
     case LASER:
       // Will probably need to use DAC instead
       digitalWrite(stim[num],HIGH);
    //    analogWriteResolution(12);
    //    analogWrite(DAC0,4095);
       break;
   }

}

void stimOff(int num) {
   switch (stim[num]) {
     case GREENLED:
       digitalWrite(stim[num],LOW);
       break;
     case LED:
       digitalWrite(stim[num],LOW);
       break;
     case WHISKER:
       digitalWrite(stim[num],LOW);
       break;
     case PUFF:
       digitalWrite(stim[num],LOW);
       break;
     case TONE:
//       noTone(stim[num]);
       break;
     case LASER:
       // Will probably need to use DAC instead
       digitalWrite(stim[num],LOW);
    //    analogWrite(DAC0,0);
       break;
   }

}

void updateReadings() {
    if (sample_counter < num_data_pts) {
      encoder_counts[sample_counter] = cylEnc.read();
      sample_times[sample_counter] = millis() - start_ms;

      sample_counter += 1;
    }

}

// Lists of functions so we can use loops to start them
void (*delay_function[6])() = {
  delay0, delay1, delay2,
  delay3, delay4, delay5
};

// Lists of functions so we can use loops to start them
void (*duration_function[6])() = {
  duration0, duration1, duration2,
  duration3, duration4, duration5
};

void trigger(){
  // Set start clock
  RUNNING = true;
  start_ms=millis();

  // Trigger camera to start
  digitalWrite(CAMERA, HIGH);  // Camera will collect the number of frames that we specify while TTL is high

  // Set up sampling interval for all readings we want
  sample_counter = 0;
  Timer6.attachInterrupt(updateReadings);
  Timer6.start(sample_interval*1000);

  // Start delay timers
  for (int i=0; i<NUMTIMERS; i++) {
    if (stim[i] > 0) {
      timer_list[i]->attachInterrupt(delay_function[i]);
      timer_list[i]->start((delays[i])); // set timer for delay period and start it
    }
    // Don't need the following lines if we call clearTimers() before each trigger
    // else {
    //   timer_list[i]->stop());
    //   timer_list[i]->detachInterrupt();
    // }
  }

}

// Use function template so we can use this for any type
// http://www.cplusplus.com/doc/tutorial/functions2/
// If we want to use templates we have to declare them in a .h file
 void convertLongArrayToByteArray(long *int_array, byte *byte_array, unsigned long num_values) {
   // Decompose a long int array into a byte array --> result will be 4x longer, least sig byte first
   int int_array_len = sizeof(int_array) / sizeof(long);
   for (int i=0; i<num_values; i++) {
     byte_array[i*4]   = (int_array[i] & 0x000000ff);
     byte_array[i*4+1] = (int_array[i] & 0x0000ff00) >> 8;
     byte_array[i*4+2] = (int_array[i] & 0x00ff0000) >> 16;
     byte_array[i*4+3] = (int_array[i] & 0xff000000) >> 24;
   }
 }

 void convertByteArrayToLongArray(byte *byte_array, long *int_array, unsigned long num_values) {
     int int_array_len = sizeof(int_array) / sizeof(long);
     for (int i=0; i<num_values; i++) {
 //        int_array[i] = (byte_array[i*4] & 0x000000ff) + (byte_array[i*4+1] & 0x0000ff00) << 8
 //                        + (byte_array[i*4+2] & 0x00ff0000) << 16 + (byte_array[i*4+3] & 0xff000000) << 24;
         int_array[i] = byte_array[i*4] + byte_array[i*4+1] << 8 + byte_array[i*4+2] << 16
                       + byte_array[i*4+3] << 24;
     }
 }


void convertVarToByteArray(long var, byte *byte_array) {
    byte_array[0] = (var & 0x000000ff);
    byte_array[1] = (var & 0x0000ff00) << 8;
    byte_array[2] = (var & 0x00ff0000) << 16;
    byte_array[3] = (var & 0xff000000) << 24;
}


unsigned int convertByteArrayToVar(byte *byte_array) {
    unsigned int var;

    var = byte_array[0] + byte_array[1] << 8 + byte_array[2] << 16 + byte_array[3] << 24;

    return (var);

}


void sendValues(long *values) {
  byte values_byte[num_data_pts*sizeof(long)];
  byte long_byte[4];

  convertVarToByteArray(num_data_pts,long_byte);

  convertLongArrayToByteArray(values,values_byte,num_data_pts);
//  convertArrayToByteArray(values,values_byte,num_data_pts);
  Serial.write(long_byte,sizeof(long_byte));
  Serial.write(values_byte,sizeof(values_byte));
}

void sendVariables() {
    Serial.write(ENCODER_L);
    sendValues(encoder_counts);
    Serial.write(TIME_L);
    sendValues(sample_times);
}


void flushSerial() {
  while (Serial.available() > 0) {Serial.read();}
}


void endOfTrial() {
  // Run all code here that needs to happen at end of trial
  unsigned long wait_time = millis();

  digitalWrite(CAMERA, LOW);
  Timer6.stop().detachInterrupt();    // Stop updating samples

  // Now wait until Matlab tells us to start transmitting the data and then transmit the stored data arrays

}

void clearTimers() {
  for (int i=0; i<NUMTIMERS; i++) {
    timer_list[i]->stop().detachInterrupt();
  }

}

void setupPuffTrial() {
  for (int i=0;i<NUMTIMERS;i++) {
    stim[i]=0;
  }
  stim[2]=PUFF;
}

void setupPairedTrial() {
  for (int i=0;i<NUMTIMERS;i++) {
    stim[i]=0;
  }
  stim[0]=GREENLED;
  stim[2]=PUFF;
}

void setupPairedLaserTrial() {
  for (int i=0;i<NUMTIMERS;i++) {
    stim[i]=0;
  }
  stim[0]=GREENLED;
  stim[1]=LASER;
  stim[2]=PUFF;
}

void setup() {

  pinMode(LED, OUTPUT);
  pinMode(LASER, OUTPUT); // This will need to change for DAC
  pinMode(PUFF, OUTPUT);
  pinMode(CAMERA, OUTPUT);
  pinMode(WHISKER, OUTPUT);
  pinMode(GREENLED, OUTPUT);

  digitalWrite(LED,LOW);
  digitalWrite(LASER, LOW); // This will need to change for DAC
  digitalWrite(PUFF, LOW);
  digitalWrite(CAMERA, LOW);
  digitalWrite(WHISKER, LOW);
  digitalWrite(GREENLED, LOW);

  Serial.begin(115200);

}

void loop() {

  unsigned long int now;

  // // TODO: replace this part with Serial.serialEvent() handler function
  // if (Serial.available() > 0) {
  //   switch (Serial.read()) {
  //     case 1:
  //       trigger();
  //       break;
  //     case 2:
  //       setupTimers();
  //       break;
  //
  //   }
  // }
  if (Serial.available() > 0) {
        switch (Serial.read()) {
            case 1:
                // Trigger
                clearTimers();
                setupPuffTrial();
                trigger();
                break;
            case 2:
                // Trigger
                clearTimers();
                setupPairedTrial();
                trigger();
                break;
            case 3:
                // Trigger
                clearTimers();
                setupPairedLaserTrial();
                trigger();
                break;

        }

  }

  if (RUNNING) {
    now = millis();
    if (now-start_ms > trial_duration) {
      RUNNING = false;
      endOfTrial();
    }

  }

}

// void serialEvent() {
//     while (Serial.available()) {
//         switch (Serial.read()) {
//             case 1:
//                 // Trigger
//                 trigger();
//                 break;
//             case 2:
//                 // Receive variables
//                 getVariables();
//                 break;
//             case 3:
//                 // Send variables
//                 sendVariables();
//                 break;
//         }

//   }
// }


/*
 Tone generator for Arduino Due
 v1  use timer, and toggle any digital pin in ISR
   funky duration from arduino version
   TODO use FindMckDivisor?
   timer selected will preclude using associated pins for PWM etc.
    could also do timer/pwm hardware toggle where caller controls duration



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
*/
