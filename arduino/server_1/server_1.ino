#include <ESP8266WiFi.h>
// #include <ESP8266WebServer-impl.h>
#include <ESP8266WebServer.h>
// #include <ESP8266WebServerSecure.h>
// #include <Parsing-impl.h>
// #include <Uri.h>

const char* ssid = "iptime_shimmer";
const char* password = "whatInTarnation";

ESP8266WebServer server(80);

void handle_root();

const char html[] PROGMEM = R"rawliteral(
  <!DOCTYPE html>
  <html>
  <body>
  <center>
  <h1>Web Server Initialized</h1>
  </center>
  </body>
  </html>
  )rawliteral";

void handle_root(){
  server.send(200,"text/html",html);
}

void setup(){
  Serial.begin(115200);
  Serial.println("ESP32 Web Server initialized");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED){
    delay(1000);
    Serial.print(".");
  }
  Serial.println();

  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

  server.on("/",handle_root);
  server.begin();

  Serial.println("HTTP Server Initialized");
  delay(100);
}

void loop(){
  server.handleClient();
}