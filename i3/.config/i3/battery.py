import os
import sys

energy_curr = float(os.popen("upower -i /org/freedesktop/UPower/devices/battery_BAT0 | awk '/energy:/{print $2}'").read().strip())
energy_full = float(os.popen("upower -i /org/freedesktop/UPower/devices/battery_BAT0 | awk '/energy-full:/{print $2}'").read().strip())

bat=(energy_curr*100/energy_full)

if bat == 100.0:
    bat = 100
else:
    bat = round(bat, 2)

print(f"BAT: {bat}%")

if bat < 30.0:
    sys.exit(33)
