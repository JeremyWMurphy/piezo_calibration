
const uint Fs = 1000; // sampling rate
IntervalTimer t1;
volatile uint32_t loopCount= 0;



const uint analogOutPin = 38;
volatile bool Go = false;
const uint waveDur = 100;
const uint waveIPI = 100;
const uint nRep = 5;

volatile uint16_t waveAmp = 0;
const uint trialITI = 5000; 

volatile uint16_t waveVal = 0;
volatile uint16_t priorWaveVal = 0;
volatile bool waveValChange = false;

volatile uint durCntr = 0;
volatile uint ipiCntr = 0;
volatile uint repCntr = 0;
volatile uint itiCntr = 0;

// Serial coms
const byte numChars = 255;
volatile char receivedChars[numChars];
volatile bool newData = false;
volatile char msgCode; // "G" - go or stop, "A" - pulse amplitude  
volatile uint32_t msgVal; // parameter value

void setup() {

  // put your setup code here, to run once:
  Serial.begin(115200); // baud rate here doesn't matter for teensy
  Serial.println("Connected");
  t1.begin(it, 1E6/Fs);

  analogReadResolution(10);
  analogWriteResolution(10);

  analogWrite(analogOutPin,0);
  
}

void it(){

  //if (loopCount % 10 == 0){
  valIn = analogRead(analogInPin);  // read the input pin
  Serial.println(valIn);
    
  setWaveVal();
  recvWithStartEndMarkers();
  parseData();

  if (Go){
    if (waveValChange){
      analogWrite(analogOutPin,waveVal);
    }
  }
  
  loopCount++;

}

void setWaveVal(){

  priorWaveVal = waveVal;

  if (itiCntr > trialITI) {
    
    if (repCntr < nRep) {

      if (durCntr < waveDur){ // not at end of pulse so continue
        waveVal = waveAmp;
        durCntr++;        
      } else if (ipiCntr < waveIPI){ //ipi
        waveVal = 0;
        ipiCntr++;        
      } else { //end of a pulse
        repCntr++;
        durCntr = 0;
        ipiCntr = 0;          
      }
    } else { // end of stim train
  
      waveVal = 0;      
      durCntr = 0;
      ipiCntr = 0;
      repCntr = 0;
      itiCntr = 0;

    }

  } else {
    itiCntr++;
    //Serial.print("itiCntr: ");
    //Serial.println(itiCntr);
  }

  if (priorWaveVal == waveVal){
    waveValChange = false;
  } else {
    waveValChange = true;
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

    volatile char * strtokIndx; // this is used by strtok() as an index

    strtokIndx = strtok((char *) receivedChars,",");      // get the first part - the string
    msgCode = *strtokIndx;
    
    
    strtokIndx = strtok(NULL, ","); // this continues where the previous call left off
    msgVal = atoi((const char *) strtokIndx);     // convert this part to an integer


    Serial.print("Message Recieved: ");
    Serial.print(msgCode);
    Serial.print(",");
    Serial.println(msgVal);
    
    if (msgCode == 'G'){ 
      if (msgVal == 1){
        Go = true;
      }  else if (msgVal == 0){
        Go = false;
      }
    } else if (msgCode == 'A'){
      waveAmp = msgVal;
    }
    
    newData = false;

  }

}

    
void loop() {
  // put your main code here, to run repeatedly:

}




