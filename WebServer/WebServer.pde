/*
 * Web Server
 *
 */

#include "WiFly.h"
#include "Credentials.h"
#include <DmxSimple.h>

#define BUFSIZE 255
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

Server server(80);

void setup() {
  
  pinMode(DMX_dir, OUTPUT); 
  pinMode (LED2, OUTPUT);
  pinMode (LED3, OUTPUT);
  
  digitalWrite(DMX_dir, HIGH);  // Set direction pin of trasnsceiver to Tx.
  
  /* The most common pin for DMX output is pin 3, which DmxSimple
  ** uses by default. If you need to change that, do it here. */
  DmxSimple.usePin(3);
  DmxSimple.maxChannel(5);
  
  WiFly.begin();
  if (!WiFly.join(ssid, passphrase)) {
    while (1) {
      // Hang on failure.
    }
  }

  Serial.begin(9600);
  Serial.print("IP: ");
  Serial.println(WiFly.ip());
  
  server.begin();
  
  DmxSimple.write(MODE, 0);
  DmxSimple.write(RED, 255);
}

void loop() {
          
  
  char httpRequest[BUFSIZE] = "";
  int index = 0;
  
  // Listen for incoming clients
  Client client = server.available();
  if (client) {
    // an http request ends with a blank line
    boolean current_line_is_blank = true;
    while (client.connected()) {
      if (client.available()) {
        char c = client.read();
        //Serial.print(c);
        
        //store HTTP request in String
        if(index < BUFSIZE){
          httpRequest[index] = c;
          index++;
        }  
        
        // http request ended, we can send a response
        if (c == '\n' && current_line_is_blank) {
          
          //Convert httpRequest to String
          String urlString = String(httpRequest);
          
          //get request method GET, POST, etc.
          String rqMethod = urlString.substring(0, urlString.indexOf(' '));
          //delete uninteresting part of request string should look s.th. like /LED1/HIGH
          urlString = urlString.substring(urlString.indexOf('/'), urlString.indexOf(' ', urlString.indexOf('/')));
          
          /*String par1 = urlString.substring(urlString.indexOf('/')+1, urlString.indexOf('/', urlString.indexOf('/')+1));
          String par2 = urlString.substring(urlString.indexOf('/', urlString.indexOf('/')+1)+1, urlString.indexOf(' ', urlString.indexOf('/')));
          */
          
          urlString.toCharArray(httpRequest, BUFSIZE);
          
          //COLOR or MODE
          char *par1 = strtok(httpRequest, "/");
          //Number
          char *par2 = strtok(NULL,"/");
          //VALUE 2
          char *par3 = strtok(NULL,"/");
          char *par4 = strtok(NULL,"/");
          Serial.print("color");
          Serial.println(par1);
          Serial.print("par2");
          Serial.println(par2);
          Serial.print("par3");
          Serial.println(par3);
          Serial.print("par4");
          Serial.println(par4);     
          
          if(par1 != NULL){
            if(strcmp(par1, "COLOR") == 0){
              if(par2 != NULL){
                int color = atoi(par2) + 2; //+2 to match channel
                  if(par3 != NULL && par4 == NULL){ //set color value
                    int colorvalue = atoi(par3);
                    DmxSimple.write(MODE, 0);
                    DmxSimple.write(SPEED, 0);  
                    DmxSimple.write(color, colorvalue);
                    Serial.print("colorvalue:");
                    Serial.println(colorvalue);
                  }else if(par3 != NULL && par4 != NULL){ //fade from i to j
                    int i = atoi(par3);
                    int j = atoi(par4);
                    int interval = 1;
                    if(i > j){
                      interval = -1;
                    }
                    while(i * interval <= j){
                      DmxSimple.write(MODE, 0);
                      DmxSimple.write(SPEED, 0);
                      DmxSimple.write(color, i);
                      i+=interval;
                      Serial.println(i);
                      delay(5);
                    }
                  }
              }
            }else if(strcmp(par1, "MODE") == 0){
              if(par2 != NULL && par3 != NULL){
                int mode = atoi(par2);
                int changespeed = atoi(par3);
                
                switch (mode){
                  case 0:
                    mode = 64;
                    break;
                  case 1:
                    mode = 128;
                    break;
                  case 2:
                    mode = 192;
                    break;
                  default:
                    ;//do nothing
                }                
                
                DmxSimple.write(MODE, mode);
                DmxSimple.write(SPEED, changespeed);
                
            }            
          }
        }
                                          
          // send a standard http response header
          client.println("HTTP/1.1 200 OK");
          client.println("Content-Type: text/html");
          client.println();
          
          //send a json response
          /*
          client.println(par2);
          client.println("<br />");
          */
          break;
        }
        if (c == '\n') {
          // we're starting a new line
          current_line_is_blank = true;
        } else if (c != '\r') {
          // we've gotten a character on the current line
          current_line_is_blank = false;
        }
      }
    }
    // give the web browser time to receive the data
    delay(100);
    client.stop();
  }
  if(httpRequest[0] != '\0'){
    //Serial.println(httpRequest);
  }
}
