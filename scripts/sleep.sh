#!bin/bash

HOW_MANY_MINUTES_DIFFERENCE=$(last reboot -R | head -n 1 | awk '{print $7}' | cut -c 5-)

# /*
#
# This variable holds the unit of the boot time minutes.
#
#   last reboot -R: display the log of all reboots system had since its first initialization.
# 	 head -n 1: print just the first line of this output, otherwise, the last boot time.
# awk '{print $7}': show just the columns that contains the hour.
# 	 cut -c 5-: get just the last number of the minutes, inside the hour.
#
# */

sleep ${HOW_MANY_MINUTES_DIFFERENCE}m

# /*
#
#  sleep <number:1,2,3><unit:m,s,h>: wait before do any other thing in terminal.
#
# */

