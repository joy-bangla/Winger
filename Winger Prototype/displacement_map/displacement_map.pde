
/**

Visualize a cube which will assumes the orientation described
in a quaternion coming from the serial port. 

INSTRUCTIONS: 
This program has to be run when you have the FreeIMU_quaternion
program running on your Arduino and the Arduino connected to your PC.
Remember to set the serialPort variable below to point to the name the
Arduino serial port has in your system. You can get the port using the
Arduino IDE from Tools->Serial Port: the selected entry is what you have
to use as serialPort variable.

Copyright (C) 2011 Fabio Varesano - http://www.varesano.net/

This program is free software: you can redistribute it and/or modify
it under the terms of the version 3 GNU General Public License as
published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

****

Edited by Antonio Hermida Vazquez Ago 2013
This is a "little more graphic" version 
After to see this gorgeus program I started to think how to see the real board.
This is my contribution. 
Of course anyone can put his own board to get the same result

****

Edited by J_RPM July 2015
Modified to suit reading with Arduino file: MPU_6050_JR
...and I've changed the image

*/

import processing.serial.*;
import processing.core.PImage.*;
import processing.core.*;
import processing.core.PApplet.*;

Serial myPort;  // Create object from Serial class

//final String serialPort = "/dev/ttyUSB9"; // replace this with your serial port. On windows you will need something like "COM1".
final String serialPort = "COM3"; // replace this with your serial port. On windows you will need something like "COM1".


float [] q = new float [4];
float [] hq = null;
float [] Euler = new float [3]; // psi, theta, phi

float ax0,ax1,ay0,ay1,az0,az1, xcur=600, ycur=300, xnext=600, ynext=300;
float dax0,dax1,day0,day1,daz0,daz1,dt1,dt0,dgt1=0,dgt0=0;

PFont font;
PImage superior,inferior,ancho,estrecho;

float eu=0;
int counter=0;
int xPos=0;

    int step_down=0, step_up=0, point_up, point_down;
    double buffer[] = new double[402];
    int i=0, bfrSz=50;
    int prec_up= 5, prec_dn= 10;
    double hi_lim_up= 15.0, lo_lim_up= 4.0, hi_lim_dn= 25.0, lo_lim_dn=15.0;
    
    PImage bg;

void setup() 
{
  //PImage img= loadImage("mars.jpg");
  size(1200, 600, P3D);
  textureMode(NORMAL);
  fill(255);
  noStroke();
  background(0);
  //image(img,0,0);
  fill(255,255,255);
  rect(0,500,1200, 600);
  stroke(255,255,255);
  line(0,600,1200,600);
  stroke(255,255,255);
  line(0,300,1200,300);
  stroke(255,255,255);
  line(600,100,600,500);
  
  myPort = new Serial(this, serialPort, 115200);  
  
  // The font must be located in the sketch's "data" directory to load successfully
  font = loadFont("CourierNew36.vlw"); 
  
  
  // Loading the textures to the cube
  // The png files alow to put the board holes so can increase  realism 
  
  superior = loadImage("Arduino S.png");//Top Side
  inferior = loadImage("Arduino B.png");//Botm side
  ancho = loadImage("Arduino L.png"); //Wide side
  estrecho = loadImage("Arduino R.png");// Narrow side
 
  
 
  delay(100);
  myPort.clear();
}

// This conversion is not used [J_RPM]
/*
float decodeFloat(String inString) {
  byte [] inData = new byte[4];
  
  if(inString.length() == 8) {
    inData[0] = (byte) unhex(inString.substring(0, 2));
    inData[1] = (byte) unhex(inString.substring(2, 4));
    inData[2] = (byte) unhex(inString.substring(4, 6));
    inData[3] = (byte) unhex(inString.substring(6, 8));
  }
      
  int intbits = (inData[3] << 24) | ((inData[2] & 0xff) << 16) | ((inData[1] & 0xff) << 8) | (inData[0] & 0xff);
  return Float.intBitsToFloat(intbits);
}
*/

void readQ() {
  
    String inputString = myPort.readStringUntil('\n');
    
    if (inputString != null && inputString.length() > 0) {
      String [] inputStringArr = split(inputString, "\t");
      if(inputStringArr.length>=5){
        q[0] = float(inputStringArr[0]);
        q[1] = float(inputStringArr[1]);
        q[2] = float(inputStringArr[2]); 
        q[3] = float(inputStringArr[3]);
        ax1  = float(inputStringArr[4]);
        ay1  = float(inputStringArr[5]);
        az1  = float(inputStringArr[6]);
      
        dt1 = abs(az1);
        //println(az1+"\t"+dt1);
        
        dgt1=map(dt1, 5000,-5000,100,-100);
        //println(dt1);
        if(dgt1<-100)dgt1=-100;
        if(dgt1>100)dgt1=100;
        println(dgt1);
    }
    }
  }


void superiorImg(PImage imag) {
  beginShape(QUADS);
  texture(imag);
  // -Y "top" face
  vertex(-10, -10, -15, 0, 0);
  vertex( 10, -10, -15, 1, 0);
  vertex( 10, -10,  15, 1, 1);
  vertex(-10, -10,  15, 0, 1);

  endShape();
}

void inferiorImg(PImage imag) {
  beginShape(QUADS);
  texture(imag);

  // +Y "bottom" face
  vertex(-10,  10,  15, 0, 0);
  vertex( 10,  10,  15, 1, 0);
  vertex( 10,  10, -15, 1, 1);
  vertex(-10,  10, -15, 0, 1);
    
  endShape();
}


void anchoImg(PImage imag) {
  beginShape(QUADS);
  texture(imag);

  // +Z "front" face
  vertex(-10, -10,  15, 0, 0);
  vertex( 10, -10,  15, 1, 0);
  vertex( 10,  10,  15, 1, 1);
  vertex(-10,  10,  15, 0, 1);

  // -Z "back" face
  vertex( 10, -10, -15, 0, 0);
  vertex(-10, -10, -15, 1, 0);
  vertex(-10,  10, -15, 1, 1);
  vertex( 10,  10, -15, 0, 1);


  endShape();
}

void estrechoImg(PImage imag) {
  beginShape(QUADS);
  texture(imag);

   // +X "right" face
  vertex( 10, -10,  15, 0, 0);
  vertex( 10, -10, -15, 1, 0);
  vertex( 10,  10, -15, 1, 1);
  vertex( 10,  10,  15, 0, 1);

  // -X "left" face
  vertex(-10, -10, -15, 0, 0);
  vertex(-10, -10,  15, 1, 0);
  vertex(-10,  10,  15, 1, 1);
  vertex(-10,  10, -15, 0, 1);

  endShape();
}


void drawCube() {  
  pushMatrix();
    translate(1120,  50, 0);
    scale(3,2,2);
    
    // a demonstration of the following is at 
    // http://www.varesano.net/blog/fabio/ahrs-sensor-fusion-orientation-filter-3d-graphical-rotating-cube
    rotateZ(-Euler[2]);
    rotateX(-Euler[1]);
    rotateY(-Euler[0]);
    
    superiorImg(superior);
    inferiorImg(inferior);
    anchoImg(ancho);
    estrechoImg(estrecho);
   
    
  popMatrix();
}


void draw() {
  
  //println("a");
  readQ();
  //println("aa");
  noStroke();
  
  fill(100,100,200);
  rect(0,0, 1200,100);
  fill(255,255,255);
  //background(#000000);
  if(hq != null) { // use home quaternion
    quaternionToEuler(quatProd(hq, q), Euler);
    //text("Disable home position by pressing \"n\"", 20, VIEW_SIZE_Y - 30);
  }
  else {
    quaternionToEuler(q, Euler);
    //text("Point FreeIMU's X axis to your monitor then press \"h\"", 20, VIEW_SIZE_Y - 30);
  }
  textFont(font, 12);
  text("Euler Angles:\nYaw (psi)  : " + degrees(Euler[0]) + "\nPitch (theta): " + degrees(Euler[1]) + "\nRoll (phi)  : " + degrees(Euler[2])+"\nsteps  : " + counter, 20, 20);
  
  drawCube();
  
  //println("b");
  stepNo(dgt1);
  //stepNo(dgt1);
  //println("c");
  
  //Euler[2]-= (acos(-1.0))/2;

  while(counter>0)
  {
    
    xnext= xcur+ 20.0*cos(Euler[2]);
    ynext= ycur+ 20.0*sin(Euler[2]);
    //trokeWeight(4);
    stroke(255,0,255);
    line(xcur, ycur, xnext, ynext);
    xcur= xnext;
    ycur= ynext;
    counter--;
  }

  
    //strokeWeight(1);
  stroke(255,0,0);
  line(xPos, 600-dgt0, xPos+1, 600-dgt1);
  
  dgt0=dgt1;
  
  xPos+=1;
  line(xPos, 600-dgt0, xPos+1, 600-dgt1);
  
  dgt0=dgt1;
  
  xPos+=1;
  
  
  if(xPos>1200){
    xPos=0;
    fill(255,255,255);
    rect(0,500,1200, 600);
    stroke(255,255,255);
    line(0,600,1200,600);
  }
  
}


void keyPressed() {
  if(key == 'h') {
    println("pressed h");
    
    // set hq the home quaternion as the quatnion conjugate coming from the sensor fusion
    hq = quatConjugate(q);
    
  }
  else if(key == 'n') {
    println("pressed n");
    hq = null;
  }
}

// See Sebastian O.H. Madwick report 
// "An efficient orientation filter for inertial and intertial/magnetic sensor arrays" Chapter 2 Quaternion representation

boolean stepNo(double a){
        boolean step=false;
        
        if(i<bfrSz)
        {
            buffer[i]=a;
            i++;
            //println("b");
            return false;
        }
        print(a+ " ");
        for(int j=0; j<bfrSz; j++)
        {
            buffer[j]= buffer[j+1];
        }
        buffer[bfrSz]=a;

//        if(buffer[bfrSz- prec_dn]- buffer[bfrSz]>4.0) continue;
        i=0;
        while( buffer[i+ prec_dn]> buffer[i]-5.0 && i< bfrSz- prec_dn) i++;
        point_up=i;
        print("pnup" + point_up + " " + buffer[i]);

        while( buffer[i+ prec_up]<= buffer[i]+5.0 && i< bfrSz- prec_up) i++;
        point_down=i;
        
        print("  pndn" + i + " " + buffer[i]);
        step_down= point_down- point_up;
        while( buffer[i+ prec_up]> buffer[i]+5.0 && i<bfrSz- prec_up) i++;
        point_up=i;
        
        print("  pnup" + point_up + " " + buffer[i]);

        step_up= point_up- point_down;
        print("   "+step_down + " " + step_up+ "  "+ a+"\n");

        if(step_down<=hi_lim_dn && step_down>=lo_lim_dn && step_up<=hi_lim_up && step_up>=lo_lim_up)
        {
            step= true;
            i= bfrSz- point_up;
            counter++;
        }
        else
        {
            i=bfrSz;
        }
    return step;
}

void quaternionToEuler(float [] q, float [] euler) {
  euler[0] = atan2(2 * q[1] * q[2] - 2 * q[0] * q[3], 2 * q[0]*q[0] + 2 * q[1] * q[1] - 1); // psi
  euler[1] = -asin(2 * q[1] * q[3] + 2 * q[0] * q[2]); // theta
  euler[2] = atan2(2 * q[2] * q[3] - 2 * q[0] * q[1], 2 * q[0] * q[0] + 2 * q[3] * q[3] - 1); // phi
  
  
// When Euler[1] fails, it get  the maximum value (theta) [J_RPM]
  String theta = nf(Euler[1],2,7);
  //println(theta);
  if(theta.length() < 8)  {
    Euler[1] = 1.5;
  }
}

float [] quatProd(float [] a, float [] b) {
  float [] q = new float[4];
  
  q[0] = a[0] * b[0] - a[1] * b[1] - a[2] * b[2] - a[3] * b[3];
  q[1] = a[0] * b[1] + a[1] * b[0] + a[2] * b[3] - a[3] * b[2];
  q[2] = a[0] * b[2] - a[1] * b[3] + a[2] * b[0] + a[3] * b[1];
  q[3] = a[0] * b[3] + a[1] * b[2] - a[2] * b[1] + a[3] * b[0];
  
  return q;
}

// returns a quaternion from an axis angle representation
float [] quatAxisAngle(float [] axis, float angle) {
  float [] q = new float[4];
  
  float halfAngle = angle / 2.0;
  float sinHalfAngle = sin(halfAngle);
  q[0] = cos(halfAngle);
  q[1] = -axis[0] * sinHalfAngle;
  q[2] = -axis[1] * sinHalfAngle;
  q[3] = -axis[2] * sinHalfAngle;
  
  return q;
}

// return the quaternion conjugate of quat
float [] quatConjugate(float [] quat) {
  float [] conj = new float[4];
  
  conj[0] = quat[0];
  conj[1] = -quat[1];
  conj[2] = -quat[2];
  conj[3] = -quat[3];
  
  return conj;
}