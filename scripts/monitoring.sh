#!bin/bash
##
## Getting Datas from system:
##

ARCH=$(uname -snrvmo)
PCPU=$(cat /proc/cpuinfo | grep 'physical id' | uniq | wc -l)
VCPU=$(cat /proc/cpuinfo | grep 'processor' | uniq | wc -l)

FULLR=$(free -m | grep 'Mem:' | awk '{print $2}') 
USEDR=$(free -m | grep 'Mem:' | awk '{print $3}')
PORUR=$()
echo ${FULLR}

LBOOT=$(who -b | awk '{print $3 " " $4}')

CHECK_IF_THERE_IS_LVM=$(lvdisplay)
LVMU=$( if [ $? -eq 0 ]; then echo yes; else echo no; fi )

COON=$()

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
#echo "#Disk Usage: $disk_usage"
#echo "#CPU load: $cpu_load"
echo "#Last boot: ${LBOOT}"
echo "#LVM use: $LVMU"
#echo "#Connexions TCP: $CONN"
echo "#User log: $ULOG"
echo "#Network: IP ${IP} (${MAC})"
echo "#Sudo: $SUDO cmd"
