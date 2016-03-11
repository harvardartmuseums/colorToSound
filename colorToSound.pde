/*
Physical artwork --> Digitalization --> Sound
    (Pigment)   -->    (Pixel)     --> (frequency)  

Convert every color on Joan Miró's Mural, March 20, 1961 (pixel by pixel) to sounds    
For Project #1 of STEAM with US 
Harvard Graduate School of Education

By Ming Tu, Harvard Art Museums

Processing 2
- Press any key to toggle between color mode (fill the canvas by the current pixel being read)
and painting mode (show the painting and a moving square for selecting a pixel) 
- Click your mouse anywhere on the canvas to hear the sound converted from the clicked pixel

Reference: 
1. Pixel array example from Processing.org
https://processing.org/examples/pixelarray.html
2. Instrument from Minim library for Processing 2
http://code.compartmental.net/minim/instrument_instrument.html
3. Color to Sound by Ignacio de Salterain from OpenProcessing.org
http://www.openprocessing.org/sketch/4121
*/
  
  
import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.signals.*;
 
PImage myImg;
int direction = 1;
float signal = 0;

Minim minim;
AudioOutput out;
SineWave sine;

boolean show_color = true; 
color c;
/*
int[] myImgPixels;
*/
 

 
 
 
void setup()
{
  size(1440, 461);
  frameRate(60);
  
  myImg = loadImage("18772541_HD.jpg");
  //myImg =loadImage("43181369_HD.jpg");
   
   
  minim = new Minim(this);
  // get a line out from Minim, default bufferSize = 1024, default sample rate = 44100, bit depth = 16
  out = minim.getLineOut(Minim.STEREO);
  // create a sine wave Oscillator, set to 440 Hz, at 0.5 amplitude, sample rate from line out
  sine = new SineWave(440, 0.5, out.sampleRate());
  // set the portamento speed on the oscillator to 200 milliseconds
  sine.portamento(10);
  // add the oscillator to the line out
  out.addSignal(sine);

  
  noFill();
  noStroke();
  /*
  myImgPixels= new int[width*height];
  for(int i=0; i<width*height; i++)  myImgPixels[i] = myImg.pixels[i];
  */ 
}
 
 
 
 
void draw()
{
  /*  
  loadPixels();
  for (int i=0; i<width*height; i++)  pixels[i] = myImgPixels[i]; 
  updatePixels(); 
  */
  
  
  if (signal > myImg.width*myImg.height-1 || signal < 0)   direction = direction*(-1);

  int mX = constrain(mouseX, 0, width-1);
  int mY = constrain(mouseY, 0, height-1);
    
  if(mousePressed)  signal = mY*width + mX;
  else  signal += random(0.02, 4)*direction;  //signal += 0.33*direction; 
  
  int sX = int(signal) % width;
  int sY = int(signal) / width;

  c = myImg.get(sX, sY); 
     
  set(0, 0, myImg); 
  stroke(255);
  strokeWeight(2);
  rect(sX - 8, sY - 8, 16, 16);
  point(sX, sY);
  noStroke();
  
  if(show_color)  draw_color(); 
  



    
  // with portamento on the frequency will change smoothly
  /*
  float freq = map(hue(myImgPixels[int(signal)]), 0, 255, 261.63, 987.77);
  */
  float freq = map(red(myImg.get(sX, sY)), 0, 255, 261.63, 987.77);
  float amplitude = map(green(myImg.get(sX, sY)), 0, 255, 0, 1);
  //sine.setFreq(freq);
  out.playNote( 0.0, 1.0, new SineInstrument( freq, amplitude ) );
  out.resumeNotes();
  // pan always changes smoothly to avoid crackles getting into the signal
  // note that we could call setPan on out, instead of on sine
  // this would sound the same, but the waveforms in out would not reflect the panning
  /*
  float pan = map(pixels[int(signal)], 0, width, -1, 1);
  */
  float pan = map(blue(myImg.get(sX, sY)), 0, 255, -1, 1);
  sine.setPan(pan);
  /* 
  print ("\n Brillo= " + brightness (myImgPixels[int(signal)]) + "   hue= " + hue (myImgPixels[int(signal)]) + "  Freq= " + freq);
  */
  println(signal + ", R = " + red(myImg.get(sX, sY)) + ", G = " + green(myImg.get(sX, sY)) + ", B = " + blue(myImg.get(sX, sY)));
  frame.setTitle(int(frameRate) + " fps");
}


void keyPressed() 
{
  show_color = ! show_color ? true : false;
}
  
  
void draw_color()
{
  background(c);
}


class SineInstrument implements Instrument
{
  Oscil wave;
  Line  ampEnv;
  
  SineInstrument( float frequency, float amplitude )
  {
    // make a sine wave oscillator
    // the amplitude is zero because 
    // we are going to patch a Line to it anyway
    wave   = new Oscil( frequency, amplitude, Waves.SINE );
    ampEnv = new Line();
    ampEnv.patch( wave.amplitude );
  }
  
  // this is called by the sequencer when this instrument
  // should start making sound. the duration is expressed in seconds.
  void noteOn( float duration )
  {
    // start the amplitude envelope
    ampEnv.activate( duration, 0.5f, 0 );
    // attach the oscil to the output so it makes sound
    wave.patch( out );
  }
  
  // this is called by the sequencer when the instrument should
  // stop making sound
  void noteOff()
  {
    wave.unpatch( out );
  }
}

