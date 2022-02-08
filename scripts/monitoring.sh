#!bin/bash
##
## Getting Datas from system:
##

ARCH=$(uname -snrvmo)
PCPU=$(cat /proc/cpuinfo | grep 'physical id' | uniq | wc -l)
VCPU=$(cat /proc/cpuinfo | grep 'processor' | uniq | wc -l)

FULLR=$(free -m | grep 'Mem:' | awk '{print $2}') 
USEDR=$(free -m | grep 'Mem:' | awk '{print $3}')
PORUR=$(free -m | grep 'Mem:' | awk '{FULLR = $2} {USEDR = $3} {printf("%.2f"), (USEDR*100)/FULLR}')

FULLD=$(df -Bg | grep /dev/ | grep -v /boot | awk '{FULLD += $2} END {print FULLD}')
USEDD=$(df -Bg | grep /dev/ | grep -v /boot | awk '{USEDD += $3} END {print USEDD}')
PORUD=$(df -Bg | grep /dev/ | grep -v /boot | awk '{FULLD += $2} {USEDD += $3}  END {printf("%d"), (USEDD*100)/FULLD }')

USE_OF_CPU=$(top -bn1 | grep Cpu | cut -c 9- | awk '{printf("%.1f%%"), $1 + $3}')

LBOOT=$(who -b | awk '{print $3 " " $4}')

CHECK_IF_THERE_IS_LVM=$(lvdisplay)
LVMU=$( if [ $? -eq 0 ]; then echo yes; else echo no; fi )

NUMBER_OF_ACTIVE_CONNECTIONS=$(netstat -t | grep ESTABLISHED | wc -l)
NTCP=$(if [ ${NUMBER_OF_ACTIVE_CONNECTIONS} -eq 0 ]; then echo 0; else echo ${NUMBER_OF_ACTIVE_CONNECTIONS} ESTABLISHED; fi)

ULOG=$(users | wc -w)

IP=$(ifconfig -a | grep inet | sed -n 1p | awk '{print $2}')
MAC=$(ifconfig -a | grep ether | cut -c 15-31)

SUDO=$(cat /var/log/sudo/sudo_log | wc -l | awk '{print $1/2}')

##
## Display:
##

echo "#Archictecture: ${ARCH}"
echo "#CPU physical: ${PCPU}"
echo "#vCPU: ${VCPU}"
echo "#Memory Usage: ${USEDR}/${FULLR}MB (${PORUR}%)"
echo "#Disk Usage: ${USEDD}/${FULLD}G (${PORUD}%)"
echo "#CPU load: $USE_OF_CPU"
echo "#Last boot: ${LBOOT}"
echo "#LVM use: $LVMU"
echo "#Connexions TCP: $NTCP"
echo "#User log: $ULOG"
echo "#Network: IP ${IP} (${MAC})"
echo "#Sudo: $SUDO cmd"
