#!bin/bash

HOW_MANY_MINUTES_DIFFERENCE=$(last reboot -R | head -n 1 | awk '{print $7}' | cut -c 5-)

#
#
#

sleep ${HOW_MANY_MINUTES_DIFFERENCE}m

#
#
#
