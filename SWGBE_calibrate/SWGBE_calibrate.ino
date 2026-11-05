#include "WaveTable.h"
#include <Adafruit_MCP4728.h>
#include <CircularBuffer.hpp>
#include <Wire.h>

const uint Fs = 2000; // sampling rate
const uint analogInPin = 16;
const bool reportData = true;

// waveform parameters to be set over serial for each of the 4 DAC channels
volatile uint waveType[4] = {1,1,1,1}; // wave types: 0 = whale, 1 = square
volatile uint waveDur[4] = {0,0,0,0}; // duration of pulse, fixed for whale right now, set via serial in ms, converted to sample points
volatile uint waveAmp[4] = {0,0,0,0}; // max voltage amplitude, in 12bit - 0-4095 
volatile uint waveIPI[4] = {0,0,0,0}; // duration between pulses, set via serial in ms, converted to sample points
volatile uint waveReps[4] = {0,0,0,0}; // number of times to repeat wave pulse and interpulse interval
volatile uint rampStep[4] = {0,0,0,0}; // specific to ramping variables, still in development
volatile float whaleStep[4] = {0.0,0.0,0.0,0.0};  // specific to asymcosin variables
volatile float whalePhase[4] = {0.0,0.0,0.0,0.0};  // specific to whale variables
volatile float gaussStep[4] = {0.0,0.0,0.0,0.0};  // specific to gauss variables
volatile float gaussPhase[4] = {0.0,0.0,0.0,0.0};  // specific to gauss variables
volatile uint waveBase[4] = {0,0,0,0};   // baseline prior to stimulus onset, in ms, allows for offsets between the stimuli, set via serial in ms, converted to sample points

// waveform tracking
volatile uint wavIncrmntr[4] = {0,0,0,0}; // for keeping track of where we are in a given stimulus presentation
volatile uint repCntr[4] = {0,0,0,0}; // for keeping track of pulse repitions
volatile uint ipiCntr[4] = {0,0,0,0}; // for keeping track of where we are in an interpulse interval
volatile uint BaseCntr[4] = {0,0,0,0}; // for keeping track of where we are in a baseline period
volatile uint whaleCntr[4] = {0,0,0,0}; //
volatile uint gaussCntr[4] = { 0, 0, 0, 0 };    // tracking gauss stim
volatile uint waveParams[7] = {0,0,0,0,0,0,0};
volatile bool inIpi[4] = {false,false,false,false};
volatile bool inBase[4] = {false,false,false,false};
volatile bool stimOn[4] = {false,false,false,false};
volatile uint curVal[4] = {0,0,0,0};
volatile uint chanSelect = 0; // 

volatile bool stimEnd = false;
volatile bool present = false;
volatile bool run = false;

// Define a safe struct holding exactly one sample's worth of data
struct TelemetryPacket {
  uint16_t val0;
  uint16_t val1;
  bool val2;
};

// Create a buffer that can hold 64 packets in RAM. 
CircularBuffer<TelemetryPacket, 64> telemetryQueue;

// Serial coms
const byte numChars = 255;
char receivedChars[numChars];
volatile bool newData = false;
volatile char msgCode;

Adafruit_MCP4728 mcp;
IntervalTimer t1;

void setup() {

  analogReadResolution(12);

  Serial.begin(115200); // baud rate here doesn't matter for teensy
  Serial.println("Connected");

  Wire.begin();
  
  // Try to initialize
  if (!mcp.begin(0x60)) { // this could be 0x60 or 0x64
    Serial.println("Failed to find MCP4728 chip"); 
  } else{
    Serial.println("Found MCP4728 chip");
    mcp.setChannelValue(MCP4728_CHANNEL_A, 0);
    mcp.setChannelValue(MCP4728_CHANNEL_B, 0);
    mcp.setChannelValue(MCP4728_CHANNEL_C, 0);
    mcp.setChannelValue(MCP4728_CHANNEL_D, 0);
  }
  
  Wire.setClock(1000000); // holy fucking shit, this must be set after mcp.begin or else it doesn't work
 
  t1.begin(waveRun, 1E6/Fs);

}

// functions called by timer should be short, run as quickly as
// possible, and should avoid calling other functions if possible.

void waveRun(){
  
  if (run){
    if (present){
      waveWrite(); 
    }
    queueTelemetry();
  }

}

void waveWrite() {

  if (!stimEnd) {
    // Waveform generator loop
    for (int i = 0; i < 4; i++) {  
      if (waveDur[i] <= 0) {       
        stimOn[i] = false;
      }
      if (stimOn[i]) {                       
        if (inBase[i] && waveBase[i] > 0) {  
          curVal[i] = 0;                     
          BaseCntr[i]++;                     
          if (BaseCntr[i] >= waveBase[i]) {
            inBase[i] = false;  
            BaseCntr[i] = 0;    
          }
        } else if (inIpi[i]) {             
          curVal[i] = 0;                   
          ipiCntr[i]++;                    
          if (ipiCntr[i] >= waveIPI[i]) {  
            inIpi[i] = false;              
            ipiCntr[i] = 0;                
          }
        } else {  
          if (waveType[i] == 0) {  // Whale stim
          //------------------------------------------------------------------------
            int indexA = (int)whalePhase[i];
            int indexB = indexA + 1;
            if (indexB >= SamplesNum) {
              indexB = 0; 
            }
            float fraction = whalePhase[i] - indexA;                            
            float fineInterp = (float)asymCos[indexA] + fraction * ((float)asymCos[indexB] - (float)asymCos[indexA]); // linear interpolation           
            curVal[i] = (int)round((fineInterp / 4095.0) * (float)waveAmp[i]);
            whalePhase[i] += whaleStep[i];
            if (whalePhase[i] >= SamplesNum) {
              whalePhase[i] -= SamplesNum; 
            }

          } else if (waveType[i] == 1) {  // Square wave
            curVal[i] = waveAmp[i];
          } else if (waveType[i] == 2) {  // Ramp up
            curVal[i] = linspace((float)waveDur[i], 0, (float)waveAmp[i], wavIncrmntr[i]);
          } else if (waveType[i] == 3) {  // Ramp down
            curVal[i] = linspace((float)waveDur[i], (float)waveAmp[i], 0, wavIncrmntr[i]);
          } else if (waveType[i] == 4) {  // Pyramid
            if (wavIncrmntr[i] < waveDur[i] / 2) {
              curVal[i] = linspace((float)waveDur[i] / 2, 0, (float)waveAmp[i], wavIncrmntr[i]);
            } else {
              curVal[i] = linspace((float)waveDur[i] / 2, (float)waveAmp[i], 0, wavIncrmntr[i] - waveDur[i] / 2);
            }
          } else if (waveType[i] == 5 && waveDur[i] > 0) {  // Gauss
            
            int indexA = (int)gaussPhase[i];
            int indexB = indexA + 1;
            if (indexB >= SamplesNum) {
              indexB = 0; 
            }
            float fraction = gaussPhase[i] - indexA;                            
            float fineInterp = (float)gauss[indexA] + fraction * ((float)gauss[indexB] - (float)gauss[indexA]);
            curVal[i] = (int)round((fineInterp / 4095.0) * (float)waveAmp[i]);
            gaussPhase[i] += gaussStep[i];

            if (gaussPhase[i] >= SamplesNum) {
              gaussPhase[i] -= SamplesNum; 
            }
          }
          wavIncrmntr[i] = wavIncrmntr[i] + 1;
        }

        if (wavIncrmntr[i] > waveDur[i]) {    
          if (repCntr[i] < waveReps[i] - 1) {  
            repCntr[i] = repCntr[i] + 1;       
            whaleCntr[i] = 0;
            whalePhase[i] = 0;
            gaussCntr[i] = 0;
            gaussPhase[i] = 0.0;
            wavIncrmntr[i] = 0;  
            inIpi[i] = true;     
            curVal[i] = 0;
          } else {  
            repCntr[i] = 0;
            whaleCntr[i] = 0;
            whalePhase[i] = 0;
            gaussCntr[i] = 0;
            gaussPhase[i] = 0;
            wavIncrmntr[i] = 0;
            inIpi[i] = false;  
            stimOn[i] = false;
            curVal[i] = 0;
          }
        }
      }
    }

    mcp.setChannelValue(MCP4728_CHANNEL_A, curVal[0]);  // send the value to the dac
    mcp.setChannelValue(MCP4728_CHANNEL_B, curVal[1]);  // send the value to the dac
    mcp.setChannelValue(MCP4728_CHANNEL_C, curVal[2]);  // send the value to the dac
    mcp.setChannelValue(MCP4728_CHANNEL_D, curVal[3]);  // send the value to the dac

    // Check if all stimuli are done
    if (stimOn[0] || stimOn[1] || stimOn[2] || stimOn[3]) {
      // Still running...
    } else {
      stimEnd = true;
      present = false;
    }
  }
}

void recvSerial() {

  static boolean recvInProgress = false;
  static byte ndx = 0;
  const char startMarker = '<';
  const char endMarker = '>';
  char rc; // Removed volatile for clean hardware registry handling

  while (Serial.available() > 0 && newData == false) {
    rc = Serial.read();
    if (recvInProgress == true) {
      if (rc != endMarker) {
        receivedChars[ndx] = rc;
        ndx++;
        if (ndx >= numChars) {
          ndx = numChars - 1;
        }
      } else {
        receivedChars[ndx] = '\0';  
        recvInProgress = false;
        ndx = 0;
        newData = true; 
      }
    } else if (rc == startMarker) {
      recvInProgress = true;
    }
  }
}

void parseData() {  

  int cntr = 0;
  char *ptr;
  
  if (newData == true) {
    char *strtokIndx; 
    strtokIndx = strtok((char *)receivedChars, ",");  
    msgCode = *strtokIndx;

    if (msgCode == 'R'){
      ptr = strtok(NULL, ",");
      noInterrupts();
      run = atoi(ptr);
      interrupts();
      
    } else if (msgCode == 'P') {                                                             
      ptr = strtok(NULL, ",");
      noInterrupts();
      present = atoi(ptr);
      interrupts();
    
    } else if (msgCode == 'W') {  
      ptr = strtok(NULL, ",");
      while ((ptr != NULL) && (cntr < 7)) {
        waveParams[cntr] = atoi(ptr);
        cntr++;
        ptr = strtok(NULL, ",");
      }
      
      uint targetChan = waveParams[0];
      if (targetChan > 3) {
        Serial.println("Bad channel selection, defaulting to channel 0");
        targetChan = 0;
      }
      
      // Calculate temporal boundaries locally
      uint calculatedDur = (uint)round((waveParams[2] / 1000.0) * Fs);
      
      // the whale and gaussian have fixed minimum length, currently 25ms
      if ((waveParams[1] == 0 || waveParams[1] == 5) && calculatedDur <= SamplesNum) {
        calculatedDur = SamplesNum-1;
      }
      
      uint calculatedIPI  = (uint)round((waveParams[4] / 1000.0) * Fs);
      uint calculatedBase = (uint)round((waveParams[6] / 1000.0) * Fs);
      uint calculatedRamp = (uint)ceil((float)waveParams[3] / calculatedDur);
      float calculatedWhale = (float)(SamplesNum-1) / (float)calculatedDur;
      float calculatedGauss = (float)(SamplesNum-1) / (float)calculatedDur;

      // ========================================================
      // ATOMIC UPDATE ZONE: Safely push new parameters to arrays
      // ========================================================
      noInterrupts();
      chanSelect = targetChan;
      waveType[chanSelect] = waveParams[1];
      waveDur[chanSelect] = calculatedDur;
      waveAmp[chanSelect] = waveParams[3];
      waveIPI[chanSelect] = calculatedIPI;
      waveReps[chanSelect] = waveParams[5];
      waveBase[chanSelect] = calculatedBase;
      rampStep[chanSelect] = calculatedRamp;
      whaleStep[chanSelect] = calculatedWhale;
      gaussStep[chanSelect] = calculatedGauss; 
      interrupts();
      // ============

    }
    
    newData = false;
  
  }
}

void queueTelemetry() {
  TelemetryPacket pack;
  pack.val0    = curVal[0];
  pack.val1    = analogRead(analogInPin); 
  pack.val2    = !stimEnd;
  telemetryQueue.push(pack);
}

int linspace(float const n, float const d1, float const d2, int const i){
  float n1 = n-1;
  return round(d1 + (i)*(d2 - d1)/n1);
}
 
void loop(){

  recvSerial(); 
  
  if (newData) {
    parseData(); 
  }

  if (reportData) {
    while (!telemetryQueue.isEmpty()) {
      // Pull the oldest unsent data packet out of the buffer
      TelemetryPacket outbound = telemetryQueue.shift(); 
      // Print using the struct data members
      Serial.print("<");
      Serial.print(outbound.val0);       Serial.print(",");
      Serial.print(outbound.val1);       Serial.print(",");
      Serial.print(outbound.val2);       Serial.print(",");
      Serial.println(">");
    }
  }
}




