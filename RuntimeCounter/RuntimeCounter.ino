#include <EEPROM.h>

/*shematic conection
 ----------------------------------------------------------------------------------------------------------
 * The LCD K should be connected to ground,
 * The A pin connected to 5v
 * lcd pin d7,d6,d5,d4,should be connected top arduino digital pin 3 -D5 respectively
 * the lcd e and rshould be connectedpins should be connected to arduino digital pin 11 & 12 respectively
 * lcd rw and vss should be connected to ground
 * vdd should be connected to 5 v
 * lcd V0 pin should be connected to postive pin of potential meter(for brighteness channging)) 
 * the two negative pins of potential meter should go to ground 

Arduino Tutorial: Learn how to use an LCD 16x2 screen
More info: http://www.ardumotive.com/how-to-use-an-lcd-dislpay-en.html  */

const int eepromStartupCounterAddress=0;

int startupCounter;
long currentRuntimeInMinutes;

long previousMilliAmpMinutes;

LiquidCrystal lcd(12, 11, 5, 4, 3, 2); // initialize the library with the numbers of the interface pins

void setup() {
  
  lcd.begin(16, 2); // set up the LCD's number of columns and rows: 
    
   // lcd.print("CURRENT.DETECTOR!"); // Print a message to the LCD.
  
  while (!Serial) {
    delay(1);  // for Leonardo/Micro/Zero
  }
  Serial.begin(57000);
  Serial.println("setup");

  //internalEepromClear();
  //delay(60000);
  
  printInternalEeprom();
  
  startupCounter = readStartupCounter();
  startupCounter++;
  if (startupCounter > 10) {
    startupCounter = 1;
  }
  writeStartupCounter(startupCounter);
  
  currentRuntimeInMinutes = 0;
  writeRuntimeCounterForStartup(startupCounter, currentRuntimeInMinutes);
}

void loop() {
  //delay(60000);
  
  // set the cursor to column 0, line 1
  // (note: line 1 is the second row, since counting begins with 0):
  lcd.setCursor(0, 1);
  //lcd.print("Codebender"); //Print a message to second line of LCD

  currentRuntimeInMinutes++;
  writeRuntimeCounterForStartup(startupCounter, currentRuntimeInMinutes);  

  long milliAmps;
  milliAmps = readMilliAmps();
  long previousMilliAmpHours;
  previousMilliAmpHours = readMilliAmpHoursForStartup(startupCounter);
  long currentMilliAmpHours;
  currentMilliAmpHours = previousMilliAmpHours + (milliAmps / (long) 60);
  writeMilliAmpHoursForStartup(startupCounter, currentMilliAmpHours);
  
  Serial.print("startupCounter: ");
  Serial.print(startupCounter);
  // lcd.print("SC");
  // lcd.print(startupCounter); /*when you uncomment this it will print startupcounter on the lcd*/
  Serial.print(" - currentRuntime: ");
  Serial.print(currentRuntimeInMinutes);
  Serial.print(" -  current milliAmps: ");
  Serial.print(milliAmps);
  Serial.print(" -  milliAmpHours: ");
  Serial.print(currentMilliAmpHours);
  //lcd.print(" mAH ");
  //lcd.print(currentMilliAmpHours); /*when you uncomment this it will print currentmilliampshours on the lcd*/
  Serial.println();
  delay(60000);
}

long readMilliAmps() {
  int m;
  m = pololuAcs711DcMilliAmps(A3, 4780, 515);
  return m;
}

// ---------------- Current sensing -------------

// https://www.pololu.com/product/2452
int pololuAcs711DcMilliAmps(int analogInputPin, int mVReference, int zeroLoadOffset) {

  // reference voltage, should be 5 V, but can vary a bit
  // with my MacBookPro and Leonardo via USB it is 5110
  //const int mVReference = 5110;
  // 36.7 * (voltage / mVReference) - 18.3

  // 136 mV / Amp for +/- 15 A version, depending on mVRef
  // 68 mV / Amp for +/- 31 A version, depending on mVRef
  const int mVperAmp = 68 ;
  
  int rawValue = sampleAnalogRead(analogInputPin, 40, 10);
  float voltage = ((rawValue - zeroLoadOffset) / 1023.0) * mVReference;
  float mamps = voltage / mVperAmp;
  return (int) (mamps * 1000);
}

int sampleAnalogRead(int analogInputPin, int sampleSize, int delayPeriod) {
  long rawValue = 0;
  int in = 0;
  for (int i = 0; i < sampleSize; i++) {
    in = analogRead(analogInputPin);
    //Serial.print(" ");
    //Serial.print(in);
    rawValue += in;
    delay(delayPeriod);
  }
  int rawValueAvg = (long) rawValue / sampleSize;
  //Serial.print(": ");
  //Serial.println(rawValueAvg);
  return rawValueAvg;
}

long readMilliAmpHoursForStartup(int counter) {
  long mah;
  EEPROM.get((counter * 2) + 1 + 500, mah);
  return mah;
}

void writeMilliAmpHoursForStartup(int counter, long mah) {
  EEPROM.put((counter * 2) + 1 + 500, mah);
}

void printInternalEeprom() {
  Serial.println("Previous runtimes");
  int startups = readStartupCounter();
  for (int i = startups; i > 0; i--) {
    Serial.print(i);
    Serial.print(" startup ");
    
    long runtimes;
    runtimes = readRuntimeCounterForStartup(i);
    Serial.print(runtimes);
    Serial.print(" mins ");
    
    long mah;
    mah = readMilliAmpHoursForStartup(i);
    Serial.print(mah);
    Serial.print(" milliamphours ");
    Serial.println();
    
    if ( i > startups - 2) /*the if statement is to control the lcd to only display two values from the loop while serially all values are being displayed*/
        {
          lcd.print("T");
          lcd.print(runtimes/100000);/*the 100000 is there to  round the number to 2 or 3 digits possible to avoid clouding the lcd*/
          delay(2000);
      
          lcd.print(" A");
          lcd.print(mah/10000000); /*the 10000000 is there to  round the number to 3 digits possible to avoid clouding the lcd*/
          delay(1000);
          }
  }
}

int readStartupCounter() {
  return EEPROM.read(eepromStartupCounterAddress);
}

void writeStartupCounter(int counter) {
  EEPROM.write(eepromStartupCounterAddress, counter);
}

long readRuntimeCounterForStartup(int counter) {
  long minutes;
  EEPROM.get((counter * 2) + 1, minutes);
  return minutes;
}

void writeRuntimeCounterForStartup(int counter, long minutes) {
  EEPROM.put((counter * 2) + 1, minutes);
}

void internalEepromClear() {
  for (int i = 0 ; i < EEPROM.length() ; i++) {
    EEPROM.write(i, 0);
  }
  Serial.println("eeprom cleared");
}

