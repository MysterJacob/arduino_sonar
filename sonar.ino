/* Example sketch to control a 28BYJ-48 stepper motor with ULN2003 driver board and Arduino UNO. More info: https://www.makerguides.com */

// Include the Arduino Stepper.h library:
#include <Stepper.h>

// Define number of steps per rotation:
const int stepsPerRevolution = 2038;
const float stepsPerDeegre = stepsPerRevolution / 360;
const int sweep_deg = 180;
const int sweep = stepsPerRevolution * (sweep_deg/360.0);
const int steps = 7;
float currentAngle = 0;
int direction = 1;
int trigPin = 3;    // TRIG pin
int echoPin = 2;    // ECHO pin

float duration_us, distance_cm;

// Create stepper object called 'myStepper', note the pin order:
Stepper stepper = Stepper(stepsPerRevolution, 8, 10, 9, 11);

void setup() {
  // Set the speed to 5 rpm:
 stepper.setSpeed(5);
   
  // Begin Serial communication at a baud rate of 9600:
  Serial.begin(115200);
  pinMode(trigPin, OUTPUT);
  // configure the echo pin to input mode
  pinMode(echoPin, INPUT);
  while(Serial.available()<=0){delay(30);};
}
float measure(int samples){
  float sum = 0;
  noInterrupts();
  for(int i =0;i<samples;i++){
    digitalWrite(trigPin, HIGH);
    delayMicroseconds(10);
    digitalWrite(trigPin, LOW);
    sum += pulseIn(echoPin, HIGH);
  }
  interrupts();
  return sum/(float)samples;
}
void writeInt(int val){
  for(int i=0;i<32;i+=8){
    Serial.write((val>>i)&255);
  }
}
void sendData(float distance,int step){
  float angle = (step / (float)sweep) * sweep_deg;
  if(direction == -1){
    angle = sweep_deg - angle;
  }
  int angle_parsed = (angle*100);
  int distance_parsed = (distance*100);
  writeInt(angle_parsed);
  writeInt(distance_parsed);
}
void loop() {
  for(int _step =0;_step < sweep;_step+=steps){
    delay(5);
    stepper.step(steps * direction);
    delay(5);

    duration_us = measure(3);
    distance_cm = 0.017 * duration_us;

    sendData(distance_cm,_step);

  }
  direction *= -1;
  delay(50);
  for(int i =0;i<8;i++)
    Serial.write(0xFE);
}
