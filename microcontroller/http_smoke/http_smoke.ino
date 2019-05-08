#include <ESP8266HTTPClient.h>
#include <ESP8266WiFi.h>

// Analog out from the sensor to Pin A0
const int smoke = A0;

int smoke_value;

void setup() {
  // Start the Serial Console
  Serial.begin(115200);

  // Wifi SSID and Password
  WiFi.begin("Bill Wi, the Science Fi", "$tevens1870");

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.println("Attempting to connect to WiFi...");
  }

  Serial.print("IP: ");
  Serial.println(WiFi.localIP());
}

void loop() {
  // Collect Current Reading
  smoke_value = analogRead(smoke) * 9.5;

  Serial.println("-------------------");

  // Print the CO Value to the console
  Serial.print("Smoke value: ");
  Serial.print(smoke_value);
  Serial.println(" ppm");

  HTTPClient http;

  // Start the req
  http.begin("http://192.168.1.175:8080");
  // Add Content Header
  http.addHeader("Content-Type", "application/json");

  int httpCode = http.POST("{ \"value\":" + String(smoke_value) + "}");
  String response = http.getString();

  Serial.print("Code: "); 
  Serial.println(httpCode);
  Serial.print("Response: "); 
  Serial.println(response);

  // End the request
  http.end();

  // Give some time before taking next reading
  delay(200);
}
