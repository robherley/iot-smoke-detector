# Setting up the Hardware

Still have a lot of work to do in terms of hardware, but I'm using an ESP8266,
which is compatible with Arduino libraries, but has an onboard chip with a full TCP/IP stack.

## MQ -2

The MQ-7 is sensitive for Smoke and other flammable gasses, and the internal
heater uses an alternating voltage of 5V and 1.4V. May also look into MQ-9, as
it can detect other gasses (that are flammable) in addition to Carbon Monoxide.

| Sensor | Arduino       |
| ------ | ------------- |
| GND    | GND           |
| DOUT   | Digital Pin 8 |
| AOUT   | Analog Pin 0  |
| VCC    | 5V            |
