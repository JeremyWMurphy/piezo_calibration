const uint Fs = 1000; // sampling rate
IntervalTimer t1;

const uint analogInPin = 33;
const uint analogOutPin = 38;
volatile uint16_t valIn = 0;
volatile uint32_t loopCount= 0;

const uint waveDur = 100;
const uint waveIPI = 100;
const uint nRep = 5;
volatile uint16_t waveVal = 0;

volatile uint durCntr = 0;
volatile uint ipiCntr = 0;
volatile uint itiCntr = 0;
volatile uint repCntr = 0;

const uint trialITI = 5000; 

volatile bool sigOn = false;
volatile bool ipiOn = false;

volatile uint16_t waveAmp = 1023;

// Serial coms
const byte numChars = 255;
volatile char receivedChars[numChars];
volatile bool newData = false;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200); // baud rate here doesn't matter for teensy
  Serial.println("Connected");
  t1.begin(it, 1E6/Fs);

  analogReadResolution(10);
  analogWriteResolution(10);

}

void it(){

  //if (loopCount % 10 == 0){
  valIn = analogRead(analogInPin);  // read the input pin
  Serial.println(valIn);     
  //} 
  
  setWaveVal();
  recvWithStartEndMarkers();
  parseData();

  analogWrite(analogOutPin,waveVal);
  
  loopCount++;

}

void setWaveVal(){

  if (itiCntr >= trialITI) {
    
    if (repCntr <= nRep) {

      if (sigOn && durCntr < waveDur){ // not at end of pulse so continue
        waveVal = waveAmp;
        durCntr++;
      } else if (sigOn && durCntr >= waveDur){ //end of pulse
        sigOn = false;
        ipiOn = true;
        waveVal = 0;
        ipiCntr = 0;
        repCntr++;
      } else if (ipiOn && ipiCntr < waveIPI){ // in ipi
        ipiCntr++;
      } else if (ipiOn && ipiCntr >= waveIPI){ // end of ipi
        sigOn = true;
        ipiOn = false;
        durCntr = 0;
      }

    } else { // end of stim train
  
      waveVal = 0;
      sigOn = false;
      ipiOn = true;
    
      durCntr = 0;
      ipiCntr = 0;
      repCntr = 0;
      itiCntr = 0;

    }

  } else {
    itiCntr++;
  }

}

void recvWithStartEndMarkers() {

  static boolean recvInProgress = false;
  static byte ndx = 0;
  const char startMarker = '<';
  const char endMarker = '>';
  volatile char rc;

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
        receivedChars[ndx] = '\0'; // terminate the string
        recvInProgress = false;
        ndx = 0;
        newData = true;
      }
    } else if (rc == startMarker) {
      recvInProgress = true;
    }
  }
}

void parseData() { // split the data into its parts

  if (newData == true) {

    char * ptr;

    ptr = strtok((char *) receivedChars,",");
    waveAmp = atoi(ptr);
    newData = false;

  }

}

    
void loop() {
  // put your main code here, to run repeatedly:

}




