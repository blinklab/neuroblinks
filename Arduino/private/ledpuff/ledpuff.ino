/*
  Conditioning
  to regulate camera, CS (LED, tone, whisker puff, ...), US. 
 */
 
// Pin 13 has an LED connected on most Arduino boards.
// give it a name:

int camera=8;
int led = 9;
int whisker = 10;
int tonech = 11;
int puff = 13;

int campretime=200;
int cs = 500;
int csch = 1;
int ISI = 200;
int us = 20;
int residual;
int tonefreq5 = 1000;


// the setup routine runs once when you press reset:
void setup() {                
  // initialize the digital pin as an output.
  pinMode(camera, OUTPUT); 
  pinMode(led, OUTPUT);     
  pinMode(puff, OUTPUT);  
  pinMode(whisker, OUTPUT);  
  Serial.begin(9600);
}

// the loop routine runs over and over again forever:
void loop() {
  // Consider using attachInterrupt() to allow better realtime control of starting and stopping, etc.
  
  checkVars();
  if (Serial.available()>0) {
    if (Serial.peek()==1) {  // This is the header for triggering; difference from variable communication is that only one byte is sent telling to trigger
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
     value = Serial.read() | Serial.read()<<8;
     
     if (header==0) {
       break;
     }
     
     switch (header) {
      case 3:
        campretime=value;
        break;
      case 4:
        csch=value;
        break;
      case 5:
        cs=value;
        break;
      case 6:
        us=value;
        break; 
      case 7:
        ISI=value;
        break;
      case 8:
        tonefreq5=value;
        break;
     }
     delay(4); // Delay enough to allow next 3 bytes into buffer (24 bits/9600 bps = 2.5 ms, so double it for safety).
  }
}


// --- function executed to start a trial ----
void Triggered() {
  // triggering camera 
  digitalWrite(camera, HIGH);
  delay(1); 
  digitalWrite(camera, LOW);
  residual=campretime-1;
  if (residual > 0) {
    delay(residual);          // wait 
  }
  
  // starting a trial
  if (cs > 0){
     switch (csch) {
       case 1:
           digitalWrite(led, HIGH);   // turn the LED on (HIGH is the voltage level)
           break; 
       case 2:
           digitalWrite(whisker, HIGH);   // turn the LED on (HIGH is the voltage level)
           break; 
       case 5:
           tone(tonech, tonefreq5, cs);   // turn the LED on (HIGH is the voltage level)
           break; 
       case 6:
           tone(tonech, tonefreq5, cs);   // turn the LED on (HIGH is the voltage level)
           break; 
     }
  }
  delay(ISI);                // wait for isi
  
  if (us > 0){
     digitalWrite(puff, HIGH);   // turn the PUFF on (HIGH is the voltage level)
     delay(us);                  // wait for us
     digitalWrite(puff, LOW);    // turn the PUFF off (HIGH is the voltage level)
  }
  
  residual=cs-ISI-us;
  if (residual > 0) {
    delay(residual);          // wait 
  }
  
  if (cs > 0){
     switch (csch) {
       case 1:
           digitalWrite(led, LOW);   // turn the LED on (HIGH is the voltage level)
           break; 
       case 2:
           digitalWrite(whisker, LOW);   // turn the LED on (HIGH is the voltage level)
           break; 
     }
  }
}

