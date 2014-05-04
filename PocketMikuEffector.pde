// PocketMiku Effector
// karaage.

import themidibus.*;
import de.humatic.mmj.*; // OSX specific
import controlP5.*;

int period = 0;

ControlP5 cp5;

DropdownList reverb, chorus, variation, vibrato;
Knob reverbDepth, chorusDepth, variationSend, variationReturn, vibratoRate, vibratoDelayMSB, vibratoDelayLSB;
Knob pitchBend, fineTuneMSB, fineTuneLSB, midiDev;
Textarea logArea;

//// Please refer http://www.humatic.de/htools/mmj/doc/
MidiOutput mo_vocaloid;  // OSX specific
MidiSystem ms;           // OSX specific

byte[] rtype0 ={(byte)0xF0, (byte)0x43, (byte)0x10, (byte)0x4C, // header(SysEx)
                (byte)0x02, (byte)0x01, (byte)0x00, (byte)0x00, (byte)0x00,
                (byte)0xF7  // footer(SysEx)
                };


byte[] rtype1 ={(byte)0xF0, (byte)0x43, (byte)0x10, (byte)0x4C, // header(SysEx)
                (byte)0x02, (byte)0x01, (byte)0x00, (byte)0x01, (byte)0x00,
                (byte)0xF7  // footer(SysEx)
                };

byte[] rtype29 ={(byte)0xF0, (byte)0x43, (byte)0x10, (byte)0x4C, // header(SysEx)
                (byte)0x02, (byte)0x01, (byte)0x00, (byte)0x13, (byte)0x00,
                (byte)0xF7  // footer(SysEx)
                };

byte[] ctype0 ={(byte)0xF0, (byte)0x43, (byte)0x10, (byte)0x4C, // header(SysEx)
                (byte)0x02, (byte)0x01, (byte)0x20, (byte)0x00, (byte)0x00,
                (byte)0xF7  // footer(SysEx)
                };


byte[] ctype1 = {(byte)0xF0, (byte)0x43, (byte)0x10, (byte)0x4C, // header(SysEx)
                (byte)0x02, (byte)0x01, (byte)0x20, (byte)0x42, (byte)0x11,
                (byte)0xF7  // footer(SysEx)
                };


byte[] ctype16 = {(byte)0xF0, (byte)0x43, (byte)0x10, (byte)0x4C, // header(SysEx)
                 (byte)0x02, (byte)0x01, (byte)0x20, (byte)0x43, (byte)0x08,
                 (byte)0xF7  // footer(SysEx)
                 };


byte[] ctype24={(byte)0xF0, (byte)0x43, (byte)0x10, (byte)0x4C, // header(SysEx)
                (byte)0x02, (byte)0x01, (byte)0x20, (byte)0x42, (byte)0x12,
                (byte)0xF7  // footer(SysEx)
                };


byte[] vtype0= {(byte)0xF0, (byte)0x43, (byte)0x10, (byte)0x4C, // header(SysEx)
               (byte)0x02, (byte)0x01, (byte)0x40, (byte)0x00, (byte)0x00, 
               (byte)0xF7  // footer(SysEx)
               };

byte[] vtype1= {(byte)0xF0, (byte)0x43, (byte)0x10, (byte)0x4C, // header(SysEx)
               (byte)0x02, (byte)0x01, (byte)0x40, (byte)0x01, (byte)0x00, 
               (byte)0xF7  // footer(SysEx)
               };


byte[] vtype30= {(byte)0xF0, (byte)0x43, (byte)0x10, (byte)0x4C, // header(SysEx)
                 (byte)0x02, (byte)0x01, (byte)0x40, (byte)0x43, (byte)0x08, 
                 (byte)0xF7  // footer(SysEx)
                 };

byte[] vtype63 = {(byte)0xF0, (byte)0x43, (byte)0x10, (byte)0x4C, // header(SysEx)
                 (byte)0x02, (byte)0x01, (byte)0x40, (byte)0x05, (byte)0x10, 
                 (byte)0xF7  // footer(SysEx)
                 };

byte[] vtype70 = {(byte)0xF0, (byte)0x43, (byte)0x10, (byte)0x4C, // header(SysEx)
                 (byte)0x02, (byte)0x01, (byte)0x40, (byte)0x48, (byte)0x00, 
                 (byte)0xF7  // footer(SysEx)
                 };

byte[] vtype75 = {(byte)0xF0, (byte)0x43, (byte)0x10, (byte)0x4C, // header(SysEx)
                 (byte)0x02, (byte)0x01, (byte)0x40, (byte)0x49, (byte)0x00, 
                 (byte)0xF7  // footer(SysEx)
                 };

byte[] vtype118= {(byte)0xF0, (byte)0x43, (byte)0x10, (byte)0x4C, // header(SysEx)
                  (byte)0x02, (byte)0x01, (byte)0x40, (byte)0x50, (byte)0x10,
                  (byte)0xF7  // footer(SysEx)
                 };

byte[] vibtypeMSBAd ={(byte)0xB0, (byte)0x63, (byte)0x70};
byte[] vibtypeLSBAd ={(byte)0xB0, (byte)0x62, (byte)0x03};
byte[] vibtypeMSBData0 ={(byte)0xB0, (byte)0x06, (byte)0x00};
byte[] vibtypeMSBData1 ={(byte)0xB0, (byte)0x06, (byte)0x01};
byte[] vibtypeMSBData2 ={(byte)0xB0, (byte)0x06, (byte)0x02};
byte[] vibtypeMSBData3 ={(byte)0xB0, (byte)0x06, (byte)0x03};

byte[] setSysEffect= {(byte)0xF0, (byte)0x43, (byte)0x10, (byte)0x4C, // header(SysEx)
                      (byte)0x02, (byte)0x01, (byte)0x5A, (byte)0x01, // set System Effect
                      (byte)0xF7  // footer(SysEx)
                     };

byte[] setInsEffect= {(byte)0xF0, (byte)0x43, (byte)0x10, (byte)0x4C, // header(SysEx)
                      (byte)0x02, (byte)0x01, (byte)0x5A, (byte)0x00, // set Insertion Effect
                      (byte)0xF7  // footer(SysEx)
                     };

void setup() {
  size(800, 600);

  cp5 = new ControlP5(this);
  reverb = cp5.addDropdownList("REVERB TYPE")
          .setPosition(50, 50)
          .setSize(100,100)
          ;

  customize(reverb); // customize the list
  addItemReverb(reverb);

  chorus = cp5.addDropdownList("CHORUS TYPE")
          .setPosition(200, 50)
          .setSize(100,100)
          ;

  customize(chorus); // customize the list
  addItemChorus(chorus);

  variation = cp5.addDropdownList("VARIATION TYPE")
          .setPosition(350, 50)
          .setSize(100,100)
          ;

  customize(variation); // customize the list
  addItemVariation(variation);

  vibrato = cp5.addDropdownList("VIBRATO TYPE")
          .setPosition(500, 50)
          .setSize(100,100)
          ;

  customize(vibrato); // customize the list
  addItemVibrato(vibrato);

  reverbDepth = cp5.addKnob("REVERB_DEPTH")
               .setRange(0,127)
               .setNumberOfTickMarks(10)
               .setValue(64)
               .setPosition(60,150)
               ;

  customizeKnob(reverbDepth);

  chorusDepth = cp5.addKnob("CHORUS_DEPTH")
               .setRange(0,127)
               .setNumberOfTickMarks(10)
               .setValue(64)
               .setPosition(210,150)
               ;

  customizeKnob(chorusDepth);


  variationSend = cp5.addKnob("VARIATION_SEND")
               .setRange(0,127)
               .setNumberOfTickMarks(10)
               .setValue(0)
               .setPosition(360,150)
               ;

  customizeKnob(variationSend);

  variationReturn = cp5.addKnob("VARIATION_RETURN")
               .setRange(0,127)
               .setNumberOfTickMarks(10)
               .setValue(64)
               .setPosition(360,250)
               ;

  customizeKnob(variationReturn);


  vibratoRate = cp5.addKnob("VIBRATO_RATE")
               .setRange(0,127)
               .setNumberOfTickMarks(10)
               .setValue(64)
               .setPosition(510,150)
               ;

  customizeKnob(vibratoRate);

  vibratoDelayMSB = cp5.addKnob("VIBRATO_DELAY1")
               .setRange(0,6)
               .setNumberOfTickMarks(6)
               .setValue(0)
               .setPosition(510,250)
               ;

  customizeKnob(vibratoDelayMSB);

  vibratoDelayLSB = cp5.addKnob("VIBRATO_DELAY2")
               .setRange(0,127)
               .setNumberOfTickMarks(10)
               .setValue(0)
               .setPosition(510,350)
               ;

  customizeKnob(vibratoDelayLSB);

  pitchBend = cp5.addKnob("PITCH_BEND")
               .setRange(0,24)
               .setNumberOfTickMarks(24)
               .setValue(16)
               .setPosition(660,150)
               ;

  customizeKnob(pitchBend);

  fineTuneMSB = cp5.addKnob("FINE_TUNE1")
               .setRange(0,127)
               .setNumberOfTickMarks(10)
               .setValue(64)
               .setPosition(660,250)
               ;

  customizeKnob(fineTuneMSB);


  fineTuneLSB = cp5.addKnob("FINE_TUNE2")
               .setRange(0,127)
               .setNumberOfTickMarks(10)
               .setValue(0)
               .setPosition(660,350)
               ;

  customizeKnob(fineTuneLSB);

  logArea = cp5.addTextarea("log")
                  .setPosition(625,30)
                  .setSize(155,60)
                  .setFont(createFont("Helvetica",14))
                  .setLineHeight(14)
                  .setColor(color(255, 255, 255))
                  .setColorBackground(color(160, 0, 0))
                  .setColorForeground(color(60));
                  ;

  detectMidiDevices();
}

void customizeKnob(Knob knob) {
  knob.setRadius(30);
  knob.setTickMarkLength(4);
  knob.snapToTickMarks(true);
  knob.setColorForeground(color(200));
  knob.setColorBackground(color(0, 160, 100));
  knob.setColorActive(color(255,255,0));
  knob.setColorCaptionLabel(color(0, 160, 0));
  knob.setDragDirection(Knob.HORIZONTAL);
}

void customize(DropdownList ddl) {
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(15);
  ddl.captionLabel().style().marginTop = 3;
  ddl.captionLabel().style().marginLeft = 3;
  ddl.valueLabel().style().marginTop = 3;
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}

void addItemReverb(DropdownList ddl) {
  ddl.captionLabel().set("REVERB TYPE");

  ddl.addItem("OFF", 0);
  ddl.addItem("HALL1", 1);
  ddl.addItem("BASEMENT", 29);
}

void addItemChorus(DropdownList ddl) {
  ddl.captionLabel().set("CHORUS TYPE");

  ddl.addItem("OFF", 0);
  ddl.addItem("CHORUS1", 1);
  ddl.addItem("FLANGER1", 16);
  ddl.addItem("ROTARY SP5", 24);

}

void addItemVariation(DropdownList ddl) {
  ddl.captionLabel().set("VARIATION TYPE");

  ddl.addItem("OFF", 0);
  ddl.addItem("HALL1", 1);
  ddl.addItem("DELAY LCR1", 30);
  ddl.addItem("FLANGER1", 63);
  ddl.addItem("PHASER1", 70);
  ddl.addItem("DIST HEAVY", 75);
  ddl.addItem("PITCH CHG1", 118);
}

void addItemVibrato(DropdownList ddl) {  
  ddl.captionLabel().set("VIBRATO TYPE");

  ddl.addItem("NORMAL", 2);
  ddl.addItem("SLIGHT", 3);
  ddl.addItem("FAST", 1);
  ddl.addItem("EXTREME", 0);
}


void draw() {  
  background(255);
}

void keyPressed(){
}

void detectMidiDevices(){
  String midiDevices[] = MidiSystem.getOutputs();
  String pokemikuName = "NSX-39  - NSX-39 ";
  int devNumb = 0;
  int detect = 0;
  for(int i = 0; i < MidiSystem.getNumberOfOutputs(); i++){
      println(i);
      println(midiDevices[i]);
    
    if(midiDevices[i].equals(pokemikuName)){
      println("NSX-39 OK");
      devNumb = i;
      detect = 1;
    }
  }

  if(detect == 1){
    logArea.setText("NSX-39 is connected. Channel is " +devNumb);
    logArea.setColorBackground(color(0, 0, 160));
  }else{
    logArea.setText("NSX-39 is not found");
    logArea.setColorBackground(color(160, 0, 0));
  }

  mo_vocaloid = ms.openMidiOutput(0);     // OSX specific
  mo_vocaloid = ms.openMidiOutput(devNumb);     // OSX specific
}

void controlEvent(ControlEvent theEvent) {
  // DropdownList is of type ControlGroup.
  // A controlEvent will be triggered from inside the ControlGroup class.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message thrown by controlP5.

  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup

    //REVERB TYPE
    if(theEvent.getGroup().getName() == "REVERB TYPE"){
      switch(int(theEvent.getGroup().getValue())){
        case 0:
          mo_vocaloid.sendMidi(rtype0);
          break;

        case 1:
          mo_vocaloid.sendMidi(rtype1);
          break; 

        case 29:
          mo_vocaloid.sendMidi(rtype29);
          break; 

        default:
          mo_vocaloid.sendMidi(rtype0);
          break;
      }
    }

    //CHORUS TYPE
    if(theEvent.getGroup().getName() == "CHORUS TYPE"){
      switch(int(theEvent.getGroup().getValue())){

        case 0:
          mo_vocaloid.sendMidi(ctype0);
          break;
        
        case 1:
          mo_vocaloid.sendMidi(ctype1);
          break; 

        case 16:
          mo_vocaloid.sendMidi(ctype16);
          break; 

        case 24:
          mo_vocaloid.sendMidi(ctype24);
          break; 

        default:
          mo_vocaloid.sendMidi(ctype0);
          break;
      }
    }

    //VARIATION TYPE
    if(theEvent.getGroup().getName() == "VARIATION TYPE"){
      switch(int(theEvent.getGroup().getValue())){

        case 0:
          mo_vocaloid.sendMidi(setInsEffect);
          break;

        case 1:
          mo_vocaloid.sendMidi(setSysEffect);
          mo_vocaloid.sendMidi(vtype1);
          break; 

        case 30:
          mo_vocaloid.sendMidi(setSysEffect);
          mo_vocaloid.sendMidi(vtype30);
          break; 

        case 63:
          mo_vocaloid.sendMidi(setSysEffect);
          mo_vocaloid.sendMidi(vtype63);
          break; 

        case 70:
          mo_vocaloid.sendMidi(setSysEffect);
          mo_vocaloid.sendMidi(vtype70);
          break; 

        case 75:
          mo_vocaloid.sendMidi(setSysEffect);
          mo_vocaloid.sendMidi(vtype75);
          break; 

        case 118:
          mo_vocaloid.sendMidi(setSysEffect);
          mo_vocaloid.sendMidi(vtype118);
          break; 

        default:
          mo_vocaloid.sendMidi(setSysEffect);
          mo_vocaloid.sendMidi(vtype0);
          break;
      }
    }

    //VIBRATO TYPE
    if(theEvent.getGroup().getName() == "VIBRATO TYPE"){
      switch(int(theEvent.getGroup().getValue())){
        case 0:
          mo_vocaloid.sendMidi(vibtypeMSBAd);
          mo_vocaloid.sendMidi(vibtypeLSBAd);
          mo_vocaloid.sendMidi(vibtypeMSBData0);
          break;

        case 1:
          mo_vocaloid.sendMidi(vibtypeMSBAd);
          mo_vocaloid.sendMidi(vibtypeLSBAd);
          mo_vocaloid.sendMidi(vibtypeMSBData1);
          break; 

        case 2:
          mo_vocaloid.sendMidi(vibtypeMSBAd);
          mo_vocaloid.sendMidi(vibtypeLSBAd);
          mo_vocaloid.sendMidi(vibtypeMSBData2);
          break; 

        case 3:
          mo_vocaloid.sendMidi(vibtypeMSBAd);
          mo_vocaloid.sendMidi(vibtypeLSBAd);
          mo_vocaloid.sendMidi(vibtypeMSBData3);
          break; 

        default:
          mo_vocaloid.sendMidi(vibtypeMSBAd);
          mo_vocaloid.sendMidi(vibtypeLSBAd);
          mo_vocaloid.sendMidi(vibtypeMSBData2);
          break;
      }
    }
  }
}

void REVERB_DEPTH(int value) {
  mo_vocaloid.sendMidi(new byte[]{(byte)0xB0, (byte)0x5B, (byte)value});
}

void CHORUS_DEPTH(int value) {
  mo_vocaloid.sendMidi(new byte[]{(byte)0xB0, (byte)0x5D, (byte)value});
}

void VARIATION_SEND(int value) {
  mo_vocaloid.sendMidi(new byte[]{(byte)0xB0, (byte)0x5E, (byte)value});
}

void VARIATION_RETURN(int value) {
  mo_vocaloid.sendMidi(new byte[]{(byte)0xF0, (byte)0x43, (byte)0x10, (byte)0x4C, // header(SysEx)
                                  (byte)0x02, (byte)0x01, (byte)0x56, (byte)value, (byte)0xF7});
}

void VIBRATO_RATE(int value) {
  mo_vocaloid.sendMidi(new byte[]{(byte)0xB0, (byte)0x63, (byte)0x70});
  mo_vocaloid.sendMidi(new byte[]{(byte)0xB0, (byte)0x62, (byte)0x04});
  mo_vocaloid.sendMidi(new byte[]{(byte)0xB0, (byte)0x06, (byte)value});
}

void VIBRATO_DELAY1(int value) {
  mo_vocaloid.sendMidi(new byte[]{(byte)0xB0, (byte)0x63, (byte)0x70});
  mo_vocaloid.sendMidi(new byte[]{(byte)0xB0, (byte)0x62, (byte)0x07});
  mo_vocaloid.sendMidi(new byte[]{(byte)0xB0, (byte)0x06, (byte)value});
}

void VIBRATO_DELAY2(int value) {
  mo_vocaloid.sendMidi(new byte[]{(byte)0xB0, (byte)0x63, (byte)0x70});
  mo_vocaloid.sendMidi(new byte[]{(byte)0xB0, (byte)0x62, (byte)0x07});
  mo_vocaloid.sendMidi(new byte[]{(byte)0xB0, (byte)0x26, (byte)value});
}

void PITCH_BEND(int value) {
  mo_vocaloid.sendMidi(new byte[]{(byte)0xB0, (byte)0x65, (byte)0x00});
  mo_vocaloid.sendMidi(new byte[]{(byte)0xB0, (byte)0x64, (byte)0x00});
  mo_vocaloid.sendMidi(new byte[]{(byte)0xB0, (byte)0x06, (byte)value});
}


void FINE_TUNE1(int value) {
  mo_vocaloid.sendMidi(new byte[]{(byte)0xB0, (byte)0x65, (byte)0x00});
  mo_vocaloid.sendMidi(new byte[]{(byte)0xB0, (byte)0x64, (byte)0x01});
  mo_vocaloid.sendMidi(new byte[]{(byte)0xB0, (byte)0x06, (byte)value});
}


void FINE_TUNE2(int value) {
  mo_vocaloid.sendMidi(new byte[]{(byte)0xB0, (byte)0x65, (byte)0x00});
  mo_vocaloid.sendMidi(new byte[]{(byte)0xB0, (byte)0x64, (byte)0x01});
  mo_vocaloid.sendMidi(new byte[]{(byte)0xB0, (byte)0x26, (byte)value});
}

void exit() {
  mo_vocaloid.close(); // bye bye!
  super.exit();
}
