#!bin/bash

##############################################################
##               Getting Datas from system:                 ##
##############################################################

# 1) The architecture of your operating system and its kernel version:
ARCH=$(uname -snrvmo)

# 2) The number of physical processors:
PCPU=$(cat /proc/cpuinfo | grep 'physical id' | uniq | wc -l)

# 3) The number of virtual processors:
VCPU=$(cat /proc/cpuinfo | grep 'processor' | uniq | wc -l)

# 4) The current available RAM on your server and its utilization rate as a percentage:
FULLR=$(free -m | grep 'Mem:' | awk '{print $2}')
USEDR=$(free -m | grep 'Mem:' | awk '{print $3}')
PORUR=$(free -m | grep 'Mem:' | awk '{FULLR = $2} {USEDR = $3} {printf("%.2f"), (USEDR*100)/FULLR}')

# 5) The current available memory on your server and its utilization rate as a percentage:
FULLD=$(df -Bg | grep /dev/ | grep -v /boot | awk '{FULLD += $2} END {print FULLD}')
USEDD=$(df -Bg | grep /dev/ | grep -v /boot | awk '{USEDD += $3} END {print USEDD}')
PORUD=$(df -Bg | grep /dev/ | grep -v /boot | awk '{FULLD += $2} {USEDD += $3}  END {printf("%d"), (USEDD*100)/FULLD }')

# 6) The current utilization rate of your processors as a percentage:
USE_OF_CPU=$(top -bn1 | grep Cpu | cut -c 9- | awk '{printf("%.1f%%"), $1 + $3}')

# 7) The date and time of the last reboot:
LBOOT=$(who -b | awk '{print $3 " " $4}')

# 8) Whether LVM is active or not:
CHECK_IF_THERE_IS_LVM=$(cat /etc/fstab | grep /dev/mapper/ | wc -l)
LVMU=$( if [ ${CHECK_IF_THERE_IS_LVM} -eq 0 ]; then echo no; else echo yes; fi )

# 9) The number of active connections:
NUMBER_OF_ACTIVE_CONNECTIONS=$(netstat -t | grep ESTABLISHED | wc -l)
NTCP=$(if [ ${NUMBER_OF_ACTIVE_CONNECTIONS} -eq 0 ]; then echo 0; else echo ${NUMBER_OF_ACTIVE_CONNECTIONS} ESTABLISHED; fi)

# 10) The number of users using the server:
ULOG=$(users | wc -w)

# 11) The IPv4 address of your server and its MAC (Media Access Control) address:
IP=$(hostname -I | awk '{ print($1) }')
MAC=$(cat /sys/class/net/*/address | head -n 1)

# 12) The number of commands executed with the sudo program:
SUDO=$(journalctl _COMM=sudo | grep COMMAND | wc -l)



##############################################################
##                       Display                            ##
##############################################################

#1#
echo "#Archictecture: ${ARCH}"

#2#
echo "#CPU physical: ${PCPU}"

#3#
echo "#vCPU: ${VCPU}"

#4
echo "#Memory Usage: ${USEDR}/${FULLR}MB (${PORUR}%)"

#5
echo "#Disk Usage: ${USEDD}/${FULLD}G (${PORUD}%)"

#6
echo "#CPU load: $USE_OF_CPU"

#7#
echo "#Last boot: ${LBOOT}"

#8#
echo "#LVM use: $LVMU"

#9#
echo "#Connexions TCP: $NTCP"

#10#
echo "#User log: $ULOG"

#11#
echo "#Network: IP ${IP} (${MAC})"

#12#
echo "#Sudo: $SUDO cmd"
