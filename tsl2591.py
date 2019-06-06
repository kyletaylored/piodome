#!/bin/python
import board
import busio
import adafruit_tsl2591
import json

# You can optionally change the gain and integration time:
#
# Gain
# The gain can be set to one of the following values
# (though the last value, MAX, has limited use in the
# real world given the extreme amount of gain applied):
# adafruit_tsl2591.GAIN_LOW (1x gain, bright light)
# adafruit_tsl2591.GAIN_MED (25x gain, general purpose [default])
# adafruit_tsl2591.GAIN_HIGH (428x gain, low light)
# adafruit_tsl2591.GAIN_MAX (9876x gain, extremely low light)
#
# Integration time
# The integration time can be set between 100 and 600ms,
# and the longer the integration time the more light the
# sensor is able to integrate, making it more sensitive in
# low light the longer the integration time.
# adafruit_tsl2591.INTEGRATIONTIME_100MS (100ms, shortest integration time (bright light) [default])
# adafruit_tsl2591.INTEGRATIONTIME_200MS (200ms)
# adafruit_tsl2591.INTEGRATIONTIME_300MS (300ms)
# adafruit_tsl2591.INTEGRATIONTIME_400MS (400ms)
# adafruit_tsl2591.INTEGRATIONTIME_500MS (500ms)
# adafruit_tsl2591.INTEGRATIONTIME_600MS (600ms) # longest integration time (dim light)


class tsl2591(object):
    def __init__(
        self,
        gain=adafruit_tsl2591.GAIN_MED,
        integration_time=adafruit_tsl2591.INTEGRATIONTIME_200MS
    ):

        # Initialize sensor
        self.i2c = busio.I2C(board.SCL, board.SDA)
        self.sensor = adafruit_tsl2591.TSL2591(self.i2c)
        self.sensor.gain = gain
        self.sensor.integration_time = integration_time

    def normalize(self, number):
        return round(number, 6)

    def read_sensor(self, json_output=False):
        # Read and calculate the light level in lux.
        lux = self.sensor.lux
        # These are unsigned, the higher the number the more light of that type.
        # There are no units like lux.
        # Infrared levels range from 0-65535 (16-bit)
        infrared = self.sensor.infrared
        # Visible-only levels range from 0-2147483647 (32-bit)
        visible = self.sensor.visible
        # Full spectrum (visible + IR) also range from 0-2147483647 (32-bit)
        full_spectrum = self.sensor.full_spectrum
        # Compile object.
        output = {
            'lux': self.normalize(lux),
            'visible': visible,
            'infrared': infrared,
            'full': full_spectrum,
            'gain': self.sensor.gain,
            'integration_time': self.sensor.integration_time
        }

        # Print JSON output
        if json_output == True:
            return json.dumps(output)

        # By default, print object
        return output


# Run code, get values.
if __name__ == '__main__':

    try:
        tsl = tsl2591()
        res = tsl.read_sensor(json_output=True)
    except (FileNotFoundError, RuntimeError) as e:
        # print ("Check if I2C is enabled, and that the I2C device is connected (i2cdetect -y 1).",e.errno)
        print({})
    except:
        # print ("Unexpected error")
        print({})
    else:
        print(res)
