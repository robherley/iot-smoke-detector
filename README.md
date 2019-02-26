# IOT Carbon Monoxide/Smoke Detector

CS-523: IOT with iOS

Robert Herley

## Description
Utilizing a Raspberry Pi, an Arduino Uno and various [MQ Gas Sensors](https://www.mysensors.org/build/gas), this project hopes to be a 100% open source real-time CO/Smoke IOT device that people can build and install in their homes. The gas levels can be monitored via the client apps (iOS and watchOS) and users can set different levels of alerts.

The design of the hardware is quite simple, the Arduino collects analog readings from the array of sensors and sends them digitally to the Raspberry Pi, which is running a Node.js server. The data will then be sent to client devices via sockets and/or HTTP requests, and also stored incrementally in a database for persistant (time-series) storage.

_TODO: Images/Diagram Here_

## Features
1. Hardware will be an always-on internet connected Arduino and/or Raspberry Pi with Carbon Monoxide and Smoke sensors that will connect to the client's network.
2. The app will send notifications to the client's iOS Device and/or Apple Watch if the hardware component detects CO/Smoke, also it will display the current reading of their devices.
3. iOS Companion app will allow for users to configure warning levels (in parts-per-million) and configure how they would like to recieve notifications.
4. The watchOS app will have a similar but simplified environment compared to the iOS App.
5. The app will support HomeKit, allowing easily integration with the client's other IOT HomeKit devices.


## Frameworks

- HomeKit: [Apple Docs](https://developer.apple.com/documentation/homekit)
	- For easy integration with other smart home devices.
- UserNotifications: [Apple Docs](https://developer.apple.com/documentation/usernotifications)
	- For the iOS app to push notifications to the client when there is an alarm/warning.
- Alamofire (http requests): [GitHub](https://github.com/Alamofire/Alamofire)
	- For making web requests easier/simplified.
- socket.io-client-swift: [GitHub](https://github.com/socketio/socket.io-client-swift)
	- To connect to the server so the client can recieve real-time readings. 	

## Timeframe

|Week|Task|
|---|---|
|Feb 25  | First Deliverable |
|March 4 | Testing Hardware (MQ Sensors) |
|March 11| Raspi Node Server w/ Socket.io |
|March 18| Arduino Communications w/ Raspi |
|March 25| Initial Structure of iOS App |
|April 1 | Persistent Storage (Database) |
|April 8 | Final Iteration of iOS App |
|April 15| watchOS mini-app |
|April 22| HomeKit Integration |
|April 29| Final 🐛 Squashing|