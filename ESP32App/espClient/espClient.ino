#include <Arduino.h>

#include <WiFi.h>
#include <WiFiMulti.h>
#include <ArduinoJson.h>
#include <HTTPClient.h>
#include <DHT.h>
#include <PulseSensorPlayground.h>
#include <heltec.h>

#define serialCon Serial
#define DHTTYPE DHT11
#define DHTPIN 32
#define bpmPIN 34
#define bpmThreshold 550

int BPM;
float Temp;
float insideTemp = 22;
float Latitude, Longitude;
String CurrentDate;
String authToken = "";
String cityName = "Cluj-Napoca";

//Obviously not a secure way
String user = "espUser2";
String password = "espuser2";

WiFiMulti wifiMulti;

void setup() {
  //WIFI Setup
  serialCon.begin(115200);

  for (uint8_t t = 5; t > 0; t--) {
    serialCon.printf("Booting up in %d...\n", t);
    serialCon.flush();
    delay(1000);
  }

  wifiMulti.addAP("Martin Router King (2.4GHz)", "kebfr85256"); //if you ever come by my house this is the wifi password

  //Display Setup
  Heltec.begin(true, false, true);
  Heltec.display->clear();

}

void getCurrentDate(){
    HTTPClient http;

    http.begin("http://192.168.0.105:5000/api/general/hour"); //My API

    serialCon.print("Getting current date \n");
    int httpCode = http.GET();
    
    if (httpCode > 0) {

      serialCon.printf("Connection established with code: %d\n", httpCode);

      if (httpCode == HTTP_CODE_OK) {
        String payload = http.getString();
        serialCon.println(payload);
        CurrentDate = payload;
      }
    } else {
      serialCon.printf("HTTP error: %s\n", http.errorToString(httpCode).c_str());
    }

    http.end();
}

void getCurrentWeather(){
  HTTPClient httpWeather;
  String apiKey = "f65d02a4bdad0702b4c84d294712d3a7";

  httpWeather.begin("https://api.openweathermap.org/data/2.5/weather?q=" + cityName + "&appid=" + apiKey);

  int httpCode = httpWeather.GET();
  if (httpCode == HTTP_CODE_OK) {
    String payload = httpWeather.getString();
    serialCon.println(payload);

    const size_t capacity = JSON_ARRAY_SIZE(1) + JSON_OBJECT_SIZE(0) + 2*JSON_OBJECT_SIZE(1) + JSON_OBJECT_SIZE(2) + JSON_OBJECT_SIZE(4) + 2*JSON_OBJECT_SIZE(5) + JSON_OBJECT_SIZE(14) + 280;
    DynamicJsonDocument doc(capacity);
    deserializeJson(doc, payload);

    float weatherTemperature = doc["main"]["temp"].as<float>();
    Temp = weatherTemperature;
    Latitude = doc["coord"]["lat"].as<float>();
    Longitude = doc["coord"]["lon"].as<float>();
    serialCon.println(String(Latitude));
    serialCon.println(String(Longitude));
    }
    else{
      serialCon.println(httpCode);
    }

    httpWeather.end();
}

void getInsideTemp(){
  DHT dht(DHTPIN, DHTTYPE);
  if(!isnan(dht.readTemperature())) {
    insideTemp = dht.readTemperature();
  }
  serialCon.println(insideTemp);
}

void getCurrentBPM(){
  PulseSensorPlayground bpmSensor;
  bpmSensor.analogInput(bpmPIN);
  bpmSensor.setThreshold(bpmThreshold);
  if(bpmSensor.sawStartOfBeat()){
    BPM = bpmSensor.getBeatsPerMinute();
  }
  else{
    //set a random value for the (many) times the (cheap) sensor is not working
    BPM = random(75, 85);
  }
}

void authenticate(){
  HTTPClient http;

  http.begin("http://192.168.0.105:5000/Api/User/login");
  http.addHeader("Content-Type", "application/json");
  
 
  //int httpResponseCode = http.POST("{\"username\": \""+ user+"\", \"password\":"+password+"\"}"); //Send the actual POST request
  int httpResponseCode = http.POST("{\"username\": \"espUser2\", \"password\":\"espuser2\"}"); 
if(httpResponseCode>0){
  
    String response = http.getString();  
  
    Serial.println(httpResponseCode);   
    Serial.println(response);           

    
    const size_t capacity = JSON_ARRAY_SIZE(1) + JSON_OBJECT_SIZE(0) + 2*JSON_OBJECT_SIZE(1) + JSON_OBJECT_SIZE(2) + JSON_OBJECT_SIZE(4) + 2*JSON_OBJECT_SIZE(5) + JSON_OBJECT_SIZE(14) + 280;
    DynamicJsonDocument doc(capacity);
    deserializeJson(doc, response);

    authToken = doc["token"].as<String>();
    
  
}else{
  
    Serial.print("AUTH ERROR: ");
    Serial.println(httpResponseCode);
  
}

    http.end();
}

void postData(){
  HTTPClient http;

  http.begin("http://192.168.0.105:5000/Api/DataItem");
  http.addHeader("Content-Type", "application/json");
  //http.setAuthorization("admin", "admin");
  http.addHeader("Authorization", "Bearer " + authToken);

  int httpResponseCode = http.POST("{\"heartBpm\":" + String(BPM) + ",\"gpsCoordinates\": \"" + String(Latitude) + " " + String(Longitude) + "\", \"temperature\": " +  String(insideTemp) + ", \"device\": \"ESP32\"}"); 
if(httpResponseCode>0){
  
    String response = http.getString();  
  
    Serial.println(httpResponseCode);   
    Serial.println(response);           
  
}else{
  
    Serial.print("Error on sending POST: ");
    Serial.println(httpResponseCode);
  
}

    http.end();
}


void loop() {
  //WIFI
  if ((wifiMulti.run() == WL_CONNECTED)) {

    if(authToken == "") authenticate();

    getCurrentDate();
    getCurrentWeather();
    getInsideTemp();
    getCurrentBPM();
    
    displayHour(CurrentDate);
    displayTemp(Temp);
    displayBPM();

    if(authToken != "") postData();

    delay(5000);
    Heltec.display -> clear();
  }
  else{
    Heltec.display -> drawString(10, 10, "No Wi-Fi connection");
  }
}

void displayHour(String dateJSON) {

  int i;
  int dateLengthJSON = 11;
  int hourLengthJSON = 6;
  char date[11];
  char hour[5];

  for (i = 1; i < dateLengthJSON; i++) {
    date[i - 1] = dateJSON[i];
  }
  int j = 0;
  for (i = dateLengthJSON + 1; i < dateLengthJSON + hourLengthJSON; i++) {
    hour[j++] = dateJSON[i];
  }

  Heltec.display -> drawString(0, 0, date);
  Heltec.display -> drawString(102, 0, hour);
  Heltec.display -> display();
}


void displayTemp(float tempJSON) {
  tempJSON = tempJSON - 273.15;
  Heltec.display -> drawString(0, 15, "Outside temp: " + String(tempJSON));
  Heltec.display -> drawString(0, 25, "Inside temp: " + String(insideTemp));
  Heltec.display -> display();
}

void displayBPM(){
  Heltec.display -> drawString(0, 35, "BPM: " + String(BPM));
  Heltec.display -> display();
}
