// SPDX-FileCopyrightText: 2025 Liz Clark for Adafruit Industries
//
// SPDX-License-Identifier: MIT

// m2 pitch = 0.4 mm
// motor: 200 steps
// TMC2209 default is 1/8 microstepping, 200*8 = 1600 steps per rotation
// 0.4mm/1600 = 0.00025mm/step or 0.25 microns

const int DIR = 6;
const int STEP = 5;

// const int HZ = 18;
const int VZ = 19;;
const int SEL = 17;
const int TARE = 18;

const int highSpeed = 5;
const int lowSpeed = 200;

volatile bool speedToggle = false;
uint32_t lastToggle;

uint32_t lastTare;

const int dBounceT = 500;

int32_t steps = 0;
float distance = 0.00;
const float umPerStep = 0.25;

void setup()
{
  // setup step and dir pins as outputs
  pinMode(STEP, OUTPUT);
  pinMode(DIR, OUTPUT);
  pinMode(SEL, INPUT_PULLUP);
  pinMode(TARE, INPUT_PULLUP);
}

void loop() {

  if (digitalRead(SEL)==LOW){
    if (millis() - lastToggle > dBounceT){
      speedToggle = !speedToggle;
      lastToggle = millis();
    }
  }

  if (digitalRead(TARE)==LOW){
    if (millis() - lastTare > dBounceT){
      steps = 0;
      lastTare = millis();
    }
  }

  if (speedToggle){
      
    if (analogRead(VZ) > 600){
      digitalWrite(DIR,HIGH);  
      digitalWrite(STEP, HIGH);
      delayMicroseconds(highSpeed);
      digitalWrite(STEP, LOW);
      delayMicroseconds(highSpeed);
      steps++;
    } else if (analogRead(VZ) < 400){
      digitalWrite(DIR,LOW);  
      digitalWrite(STEP, HIGH);
      delayMicroseconds(highSpeed);
      digitalWrite(STEP, LOW);
      delayMicroseconds(highSpeed);
      steps--;
    }

  } else {

    if (analogRead(VZ) > 600){
      digitalWrite(DIR,HIGH);  
      digitalWrite(STEP, HIGH);
      delayMicroseconds(lowSpeed);
      digitalWrite(STEP, LOW);
      
      delayMicroseconds(lowSpeed);
      steps++;
    } else if (analogRead(VZ) < 400){
      digitalWrite(DIR,LOW);  
      digitalWrite(STEP, HIGH);
      delayMicroseconds(lowSpeed);
      digitalWrite(STEP, LOW);
      delayMicroseconds(lowSpeed);
      steps--;
    }

  }

  Serial.println((float) steps * umPerStep);

}
