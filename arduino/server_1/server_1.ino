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

// const char pageMain[] PROGMEM = R"=====(
// <!doctype html>
// <html>
// <head>
// 	<title>Main Page</title>
// </head>
// <body>
// 	<h1>This is Main page</h1>
// 	<p><a href="/">Main Page</a></p>
// 	<p><a href="/second_page">Second Page</a></p>
// 	<p><a href="/thrid_page">Thrid Page</a></p>
// </body>
// </html>
// )=====";
 
// const char pageSecond[] PROGMEM = R"=====(
// <!doctype html>
// <html>
// <head>
// 	<title>Second Page</title>
// </head>
// <body>
// 	<h1>This is Second page</h1>
// 	<p><a href="/">Main Page</a></p>
// 	<p><a href="/second_page">Second Page</a></p>
// 	<p><a href="/thrid_page">Thrid Page</a></p>
// </body>
// </html>
// )=====";
 
// const char pageThrid[] PROGMEM = R"=====(
// <!doctype html>
// <html>
// <head>
// 	<title>Thrid Page</title>
// </head>
// <body>
// 	<h1>This is Thrid page</h1>
// 	<p><a href="/">Main Page</a></p>
// 	<p><a href="/second_page">Second Page</a></p>
// 	<p><a href="/thrid_page">Thrid Page</a></p>
// </body>
// </html>
// )=====";

// void handleMain() {
// 	String html = pageMain;
// 	server.send(200, "text/html", html);
// }
 
// void handleSecondPage() {
// 	String html = pageSecond;
// 	server.send(200, "text/html", html);
// }
 
// void handleThridPage() {
// 	String html = pageThrid;
// 	server.send(200, "text/html", html);
// }
 
// void setup()
// {
// 	Serial.begin(115200);
// 	WiFi.mode(WIFI_STA);
// 	WiFi.begin(ssid, password);
 
// 	while (WiFi.status() != WL_CONNECTED) {
// 		delay(500);
// 		Serial.print(".");
// 	}
// 	Serial.println("");
// 	Serial.print("Connecting to ");
// 	Serial.println(ssid);
// 	Serial.print("IP address: ");
// 	Serial.println(WiFi.localIP());
 
// 	server.on("/", handleMain);
// 	server.on("/second_page", handleSecondPage);
// 	server.on("/thrid_page", handleThridPage);
 
// 	server.begin();
// 	Serial.println("Server started");
// }
// void loop()
// {
// 	server.handleClient();
// }

// void setup() {
//   // put your setup code here, to run once:

// }

// void loop() {
//   // put your main code here, to run repeatedly:

// }