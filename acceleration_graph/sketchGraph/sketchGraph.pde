
 // Graphing sketch


// This program takes ASCII-encoded strings
// from the serial port at 9600 baud and graphs them. It expects values in the
// range 0 to 1023, followed by a newline, or newline and carriage return

// Created 20 Apr 2005
// Updated 24 Nov 2015
// by Tom Igoe
// This example code is in the public domain.

import processing.serial.*;

Serial myPort;        // The serial port
float xPos = 0;         // horizontal position of the graph
float x1=0,y1=0,z1=0;
float x0=0,y0=0,z0=0;

void setup () {
  // set the window size:
  size(800, 600);

  // List all the available serial ports
  // if using Processing 2.1 or later, use Serial.printArray()
  printArray(Serial.list());

  // I know that the first port in the serial list on my mac
  // is always my  Arduino, so I open Serial.list()[0].
  // Open whatever port is the one you're using.
  myPort = new Serial(this, Serial.list()[0], 38400);

  // don't generate a serialEvent() unless you get a newline character:
  myPort.bufferUntil('\n');

  // set inital background:
  background(0);
}
void draw () {
  // draw the line:
  
  stroke(255, 255,255);
  
  line(0, 300, 800, 300);
  
  stroke(255,0,0);
  if(x1<=590 && x1>=20){
  line(xPos, x0, xPos+0.6, x1);}
  
  stroke(0,255,0);
  if(y1<=590 && y1>=20){
  line(xPos, y0, xPos+0.6, y1);}
  
  
  stroke(0,0,255);
  if(z1<=590 && z1>=20){
  line(xPos, z0, xPos+0.6, z1);}
  //line(30, 20, 85, 20);
  x0=x1;
  y0=y1;
  z0=z1;
  xPos=xPos+0.6;


  // at the edge of the screen, go back to the beginning:
  if (xPos >= width) {
    xPos = 0;
    background(0);
  }
}


void serialEvent (Serial myPort) {
  // get the ASCII string:
  String inString = myPort.readStringUntil('\n');
  String [] inputStringArr = split(inString, " ");
  x1= float(inputStringArr[0]);
  y1= float(inputStringArr[1]);
  z1= float(inputStringArr[2]);
  
  print(x1+ " "+ y1+" "+z1+"\n");
  
  x1=(map(x1, 16384,-16384, 20,590));
  y1=(map(y1, 16384,-16384, 20,590));
  z1=(map(z1, 16384,-16384, 20,590));

  
  
   
}