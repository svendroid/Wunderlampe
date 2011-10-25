/* 
Sven Adolph / 21.10.2011
First Tests with
  - DMX Shield (http://www.skpang.co.uk/catalog/arduino-dmx-shield-p-663.html) 
  - DMX Simple library
  - PAR36 LED
*/

#include <DmxSimple.h>

//Used DMX channels, details in the spots manual
#define MODE  1
#define RED   2
#define GRN   3
#define BLU   4
#define SPEED 5

//Pin to set the transceiver
int DMX_dir = 2;

//LEDs on the DMX shield
int LED2 = 8;
int LED3 = 7;


void setup() {
  
  pinMode(DMX_dir, OUTPUT);    
  pinMode(LED2, OUTPUT);
  pinMode(LED3, OUTPUT);      
  
  digitalWrite(DMX_dir, HIGH);  // Set direction pin of trasnsceiver to Tx.
  
  /* The most common pin for DMX output is pin 3, which DmxSimple
  ** uses by default. If you need to change that, do it here. */
  DmxSimple.usePin(3);
  DmxSimple.maxChannel(5);
}

void loop() {  
  
  //turn LEDs on shield on
  digitalWrite(LED2, HIGH);
  digitalWrite(LED3, HIGH);
  
  //Different modes
  //1. RGB Control
  DmxSimple.write(MODE, 0);
  DmxSimple.write(SPEED, 0);
  //fade out
  for(int i = 0; i <= 255; i++){
    DmxSimple.write(RED, i);
    delay(5);
  }
  //fade out
  for(int i = 255; i >= 0; i--){
    DmxSimple.write(RED, i);
    delay(5);
  }
  
  //2. Seven colour fade mode
  DmxSimple.write(MODE, 64);
  DmxSimple.write(SPEED, 30);
  delay(10000); //wait 10 sec
  
  //3. Seven colour change
  DmxSimple.write(MODE, 128);
  DmxSimple.write(SPEED, 100);
  delay(10000); //wait 10 sec
  
  //4. Three colour change
  DmxSimple.write(MODE, 192);
  DmxSimple.write(SPEED, 100);
  delay(10000); //wait 10 sec
}
