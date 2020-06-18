#include <Arduino.h>

#include <WiFi.h>
#include <WiFiMulti.h>
#include <ArduinoJson.h>
#include <HTTPClient.h>

#include <heltec.h>

#define USE_SERIAL Serial

int BPM;
float Temp;
double Latitute, Longitude;
String CurrentDate;

WiFiMulti wifiMulti;

void setup() {
  //WIFI Setup
  USE_SERIAL.begin(115200);
  USE_SERIAL.println();
  USE_SERIAL.println();
  USE_SERIAL.println();

  for (uint8_t t = 4; t > 0; t--) {
    USE_SERIAL.printf("[SETUP] WAIT %d...\n", t);
    USE_SERIAL.flush();
    delay(1000);
  }

  wifiMulti.addAP("Martin Router King (2.4GHz)", "kebfr85256");

  //Display Setup
  Heltec.begin(true, false, true);
  Heltec.display->clear();

}

void loop() {
  //WIFI
  if ((wifiMulti.run() == WL_CONNECTED)) {

    HTTPClient http;

    //USE_SERIAL.print("Connection begins \n");

    http.begin("http://192.168.0.105:5000/api/general/hour"); //HTTP

    USE_SERIAL.print("[HTTP] GET...\n");
    // start connection and send HTTP header
    int httpCode = http.GET();

    // httpCode will be negative on error
    if (httpCode > 0) {

      USE_SERIAL.printf("[HTTP] GET... code: %d\n", httpCode);

      if (httpCode == HTTP_CODE_OK) {
        String payload = http.getString();
        USE_SERIAL.println(payload);

        //displayHour(payload);
        CurrentDate = payload;

      }
    } else {
      USE_SERIAL.printf("[HTTP] GET... failed, error: %s\n", http.errorToString(httpCode).c_str());
    }

    http.end();

    HTTPClient httpWeather;
    String apiKey = "f65d02a4bdad0702b4c84d294712d3a7";
    String cityName = "Cluj-Napoca";

    httpWeather.begin("https://api.openweathermap.org/data/2.5/weather?q=" + cityName + "&appid=" + apiKey);

    httpCode = httpWeather.GET();
    if (httpCode == HTTP_CODE_OK) {
      String payload = httpWeather.getString();
      USE_SERIAL.println(payload);

      const size_t capacity = JSON_ARRAY_SIZE(1) + JSON_OBJECT_SIZE(0) + 2*JSON_OBJECT_SIZE(1) + JSON_OBJECT_SIZE(2) + JSON_OBJECT_SIZE(4) + 2*JSON_OBJECT_SIZE(5) + JSON_OBJECT_SIZE(14) + 280;
    DynamicJsonDocument doc(capacity);
    deserializeJson(doc, payload);

    float weatherTemperature = doc["main"]["temp"].as<float>();
//    USE_SERIAL.println("Weather: " + weatherTemperature);
      //displayTemp(weatherTemperature);
      Temp = weatherTemperature;

    }
    else{
      USE_SERIAL.println(httpCode);
    }

    httpWeather.end();
    displayHour(CurrentDate);
    displayTemp(Temp);
    delay(5000);
    Heltec.display -> clear();
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
  Heltec.display -> drawString(0, 20, "Outside temperature: " + String(tempJSON));
  Heltec.display -> display();
}
