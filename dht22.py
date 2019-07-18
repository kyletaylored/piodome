#!/bin/python

import Adafruit_DHT


# Sensor should be set to Adafruit_DHT.DHT11,
# Adafruit_DHT.DHT22, or Adafruit_DHT.AM2302.
sensor = Adafruit_DHT.AM2302

# Example using a Beaglebone Black with DHT sensor
# connected to pin P8_11.
pin = 4


# Try to grab a sensor reading.  Use the read_retry method which will retry up
# to 15 times to get a sensor reading (waiting 2 seconds between each retry).

humidity, temperature = Adafruit_DHT.read_retry(sensor, pin)
if humidity is not None and temperature is not None:


class dht22(object):
    def __init__(
        self,
        gain=adafruit_tsl2591.GAIN_MED,
        integration_time=adafruit_tsl2591.INTEGRATIONTIME_200MS
    ):
