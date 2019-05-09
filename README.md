# IOT Smoke Detector

CS-523: IOT with iOS

Robert Herley

# Description

Utilizing a ESP-8266 and various [MQ Gas Sensors](https://www.mysensors.org/build/gas), this project hopes to be a 100% open source real-time Smoke IOT device that people can build and install in their homes. The gas levels can be monitored via the client apps and users can set different levels of alerts.

The design of the hardware is quite simple, the ESP-8266 collects analog readings from the array of sensors and sends them over HTTP to a Node.js server. The data will then be sent to client devices via sockets and/or HTTP requests. In the future, it would nice to additionally stored in a database for persistent (time-series) storage.

# Setup

## Microcontroller

For the ESP-8266, you must install the [required libraries](https://github.com/esp8266/Arduino) for the Arduino IDE, or use something like [Platform.io](https://platformio.org/).

To get it running on your network, simply change the SSID and Password to match
your router's configuration, and set the IP/PORT of the Node.JS server:

```c++
  // in http_smoke.ino

  WiFi.begin("SSID", "Password");

  ...

  http.begin("http://<Node.JS Server>:8080");
```

Then, connect the MQ-2 sensor to the analog pin (A0), VCC to 5V, and GND to GND.

## Node.JS Server

Install Dependencies:

```
npm i
```

Run the Server:

```
node app.js
```

## iOS App

Install the Required Pods:

```
pod install
```

Open the `smoke-detector.xcworkspace` in Xcode, compile and run on your desired target device.
