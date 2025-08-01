const uint Fs = 100; // sampling rate
IntervalTimer t1;

const uint analogPin = 33;
volatile uint32_t val = 0;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200); // baud rate here doesn't matter for teensy
  Serial.println("Connected");
  t1.begin(it, 1E6/Fs);

}

void it(){
  val = analogRead(analogPin);  // read the input pin
  Serial.println(val);          // debug value
}

void loop() {
  // put your main code here, to run repeatedly:

}




