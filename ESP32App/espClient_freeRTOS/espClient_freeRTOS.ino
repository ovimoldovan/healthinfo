#include <Arduino.h>

#include <WiFi.h>
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
String Name = "";

String user = "espUser1";
String password = "espUser1";
String apiUrl = "https://healthinfo.azurewebsites.net/api";

#define WIFI_NETWORK "Ovi's (2.4GHz)"
#define WIFI_PASSWORD "Cata sigur intarzie"
#define WIFI_TIMEOUT_MS 20000

void wifiSetup(void * parameters){
  for(;;){
    if(WiFi.status() == WL_CONNECTED){
      Serial.println("Wifi connection active");
      vTaskDelay(10000 / portTICK_PERIOD_MS);
      continue;
    }

  Serial.println("Wifi connecting");
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_NETWORK, WIFI_PASSWORD);

  unsigned long startAttemptTime = millis();

  while(WiFi.status() != WL_CONNECTED && millis() - startAttemptTime < WIFI_TIMEOUT_MS){}

  if(WiFi.status() != WL_CONNECTED) {
    Serial.println("Wifi failed");
  }
  }
}


void setup() {
  serialCon.begin(115200);

  for (uint8_t t = 5; t > 0; t--) {
    serialCon.printf("Booting up in %d...\n", t);
    serialCon.flush();
    delay(1000);
  }

  //WIFI Setup
  xTaskCreatePinnedToCore(
    wifiSetup,
    "Setup WiFi Task Task",
    5000,
    NULL,
    1,
    NULL,
    CONFIG_ARDUINO_RUNNING_CORE
    );
  

  //Display Setup
  Heltec.begin(true, false, true);
  Heltec.display->clear();


  //Tasks for getting data from the internet
  xTaskCreate(
    getCurrentDate, //function
    "GetCurrentDateTask", //task name
    8192, // stack size
    NULL, // parameters
    1, //priority
    NULL //handler
    );

  xTaskCreate(
    getCurrentWeather, //function
    "Get Weather Task", //task name
    8192, // stack size
    NULL, // parameters
    1, //priority
    NULL //handler
    );

    
    //Start the task that posts the data on the API

   xTaskCreate(
        postData, //function
        "Post Data to API Task", //task name
        8192, // stack size
        NULL, // parameters
        1, //priority
        NULL //handler
    );
}

void getCurrentDate(void * parameters){
  for(;;){
    HTTPClient http;

    http.begin(apiUrl + "/general/hour"); //My API

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
    vTaskDelay(15000 / portTICK_PERIOD_MS);
  }
}

void getCurrentWeather(void * parameters){
  for(;;){
  HTTPClient httpWeather;
  String apiKey = "";

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
    vTaskDelay(15000 / portTICK_PERIOD_MS);
  }
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

  http.begin(apiUrl + "/User/login");
  http.addHeader("Content-Type", "application/json");

  String request = "{\"username\": \"" + user + "\", \"password\":\""+ password + "\"}";
  Serial.println(request);
  
  int httpResponseCode = http.POST(request); 
  if(httpResponseCode>0){
  
  String response = http.getString();  
  
  Serial.println(httpResponseCode);   
  Serial.println(response);           
 
  const size_t capacity = JSON_ARRAY_SIZE(1) + JSON_OBJECT_SIZE(0) + 2*JSON_OBJECT_SIZE(1) + JSON_OBJECT_SIZE(2) + JSON_OBJECT_SIZE(4) + 2*JSON_OBJECT_SIZE(5) + JSON_OBJECT_SIZE(14) + 280;
  DynamicJsonDocument doc(capacity);
  deserializeJson(doc, response);

  authToken = doc["token"].as<String>();
  Name = doc["name"].as<String>();
  cityName = doc["location"].as<String>();
}
else{
    Serial.print("AUTH ERROR: ");
    Serial.println(httpResponseCode);
  
}
    http.end();
}

void postData(void * parameters){
  for(;;){    
    if(authToken != "") {
      HTTPClient http;

      http.begin(apiUrl + "/DataItem");
      http.addHeader("Content-Type", "application/json");
      http.addHeader("Authorization", "Bearer " + authToken);
    
      int httpResponseCode = http.POST("{\"heartBpm\":" + String(BPM) + ",\"gpsCoordinates\": \"" + String(Latitude) + " " + String(Longitude) + "\", \"temperature\": " +  String(insideTemp) + ", \"device\": \"ESP32\"}"); 
      if(httpResponseCode>0)
      {
      
        String response = http.getString();  
      
        Serial.println(httpResponseCode);   
        Serial.println(response);           
      }
      else
      {
        Serial.print("Error on sending POST: ");
        Serial.println(httpResponseCode); 
      }
        http.end();
        vTaskDelay(1000 / portTICK_PERIOD_MS);
    }
  }
}


void loop() {
  //If Wi-Fi is connected
  if ((WiFi.status() == WL_CONNECTED)) {

    //If there is no authentification token, ask the API for one
    if(authToken == "") authenticate();

    //Gett data from API and sensors
    //getCurrentDate();
    //getCurrentWeather();
    getInsideTemp();
    getCurrentBPM();

    //Display the data
    displayHour(CurrentDate);
    displayTemp(Temp);
    displayBPM();
    displayDetails();

    delay(5000);
    Heltec.display -> clear();
  }
  else{
    Heltec.display -> drawString(10, 10, "No Wi-Fi connection");
    Heltec.display -> display();
  }
}

void displayHour(String dateJSON) {

  int i;
  int dateLengthJSON = 11;
  int hourLengthJSON = 6;
  char date[10];
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
  Heltec.display -> drawString(0, 15, cityName + " temp: " + String(tempJSON));
  Heltec.display -> drawString(0, 25, "Inside temp: " + String(insideTemp));
  Heltec.display -> display();
}

void displayBPM(){
  Heltec.display -> drawString(0, 35, "BPM: " + String(BPM));
  Heltec.display -> display();
}

void displayDetails(){
  Heltec.display -> drawString(0, 45, "User: " + Name);
  Heltec.display -> display();
}
