#include <Wire.h> // For I2C communication
#include <SPI.h>  // For controlling external chips
#include <Arduino.h>
#include <stateMachine.hpp>

//This is the I2C Address of the MCP4725, by default (A0 pulled to GND).
//Please note that this breakout is for the MCP4725A0.
//Please note that this breakout is for the MCP4725A0.
#define MCP4725_ADDR 0x60   // DAC
#define MAXDACUNIT 4095       // 2^12-1 (ie 12 bits)
#define MINDACUNIT 0

void DACWrite( int );

int powerToDACUnits( int );

void setDiPoValue( int );

void checkVars( void );

void configureTrial( void );

void startTrial( void );

void endOfTrial( void );

void digitalOn(int);

void digitalOff(int);

void toneOn(int);

void toneOff(int);

void laserOn(int);

void laserOff(int);

void takeEncoderReading(timems_t &, int32_t &);

void sendEncoderData( void );

void writeLong(uint32_t);

void writeLong(int32_t);

void flushReceiveBuffer();
