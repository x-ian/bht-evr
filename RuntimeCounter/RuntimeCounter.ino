#include <EEPROM.h>

const int eepromStartupCounterAddress=0;

int startupCounter;
long currentRuntimeInMinutes;

long previousMilliAmpMinutes;

void setup() {
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
  delay(60000);

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
  Serial.print(" - currentRuntime: ");
  Serial.print(currentRuntimeInMinutes);
  Serial.print(" -  current milliAmps: ");
  Serial.print(milliAmps);
  Serial.print(" -  milliAmpHours: ");
  Serial.print(currentMilliAmpHours);
  Serial.println();
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

