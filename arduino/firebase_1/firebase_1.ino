#include "FirebaseESP8266.h"
#include <ESP8266WiFi.h>

#define FIREBASE_HOST "https://esp8266firebase-896b2-default-rtdb.asia-southeast1.firebasedatabase.app/"
#define FIREBASE_AUTH "YiIduBMGv5Frab0vVaPnVhHkyuNZD9Q418bF4rv7"
#define WIFI_SSID "iptime_shimmer"
#define WIFI_PASSWORD "whatInTarnation"

FirebaseData firebaseData;

void setup() {
  Serial.begin(115200);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.println();
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);

  firebaseData.setBSSLBufferSize(1024, 1024);
  firebaseData.setResponseSize(1024);
  Firebase.setReadTimeout(firebaseData, 1000 * 60);
  Firebase.setwriteSizeLimit(firebaseData, "tiny");
}

void loop() {
  static int cnt = 0;
  static unsigned long prevTime = 0;
  static unsigned long nowTime = 0;

  nowTime = millis();
  if (nowTime - prevTime >= 5000)
  {
    prevTime = nowTime;
      Firebase.setFloat(firebaseData, "/esp8266/count", cnt++);
  }
}