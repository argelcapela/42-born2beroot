#!bin/bash

##############################################################
##               Getting Datas from system:                 ##
##############################################################

# 1) The architecture of your operating system and its kernel version:
ARCH=$(uname -srvmo)

# /* 
#     'uname': print system information.
#          -s: print the kernel name.
#          -r: kernel release. (published, because among a lot of versions just few final versions are 👌😎 "leased")
#          -v: kernel version.
#          -m: hardware (32bits or 64bits for example).
#          -o: SO.  
#     
#      source: https://man7.org/linux/man-pages/man1/uname.1.html
# */


# 2) The number of physical processors:
PCPU=$(cat /proc/cpuinfo | grep 'physical id' | uniq | wc -l)

# /* 
#     What is 'physical processor'? is the number of devices on your motherboard. More advanced computers have more than one physical CPU.
#
#     'cat /proc/cpuinfo': show us a lot of information about the physical CPU.
#      grep 'physical id': the output will have more than 1 information group, because one CPU may have more than 1 cores, so we need to filter and show just, lines with the word 'physical id' present.
#                   uniq : remove similar lines, this will show exactly just the PHYSICAL amount of CPU(s).
#                  wc -l : return the amount of lines of stdout
#                      -l: count lines of stdout.
#     
#      sources: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/deployment_guide/s2-proc-cpuinfo
#               https://serverfault.com/questions/326035/what-does-siblings-mean-in-proc-cpuinfo/326050#:~:text=The%20number%20of%20siblings%20on,both%20additional%20cores%20and%20hyperthreading.
# */


# 3) The number of virtual processors, vCPU:
VCPU=$(cat /proc/cpuinfo | grep 'processor' | uniq | wc -l)

# /* 
#     What is 'virtual processor'? is a portion of Physical Processor, assigned to be used by VM(s). So the processor need to have support to it. 
#     hypervisor is like a VM monitor, or manager inside these VM compatible CPU, it allocate and deallocate the CPU resources to the VM(s).
#     
#     'cat /proc/cpuinfo': show us a lot of information about the physical CPU.
#        grep 'processor': We filter and show just, lines with the word 'processor', because it represent the amount of vCPU.
#                   uniq : remove similar lines, this will show exactly just the PHYSICAL amount of CPU(s).
#                  wc -l : return the amount of lines of stdout
#                      -l: count lines of stdout.
#     
#      sources: https://www.datacenters.com/news/what-is-a-vcpu-and-how-do-you-calculate-vcpu-to-cpu
#               
# */


# 4) The current available RAM on your server and its utilization rate as a percentage:
FULLR=$(free -m | grep 'Mem:' | awk '{print $2}')
USEDR=$(free -m | grep 'Mem:' | awk '{print $3}')
PORUR=$(free -m | grep 'Mem:' | awk '{FULLR = $2} {USEDR = $3} {printf("%.2f"), (USEDR*100)/FULLR}')

# /* 
#     
#                                                                     free : display amount of RAM used in the system.
#                                                                       -m : show the free output in MB.
#                                                              grep 'Mem:' : show just the line with 'Mem' inside, otherwise, the used memory.
#                                                         awk '{print $2}' : print the 2 column which is the total RAM.
#                                                         awk '{print $3}' : print the 3 column which is the used RAM.
#      awk '{FULLR = $2} {USEDR = $3} {printf("%.2f"), (USEDR*100)/FULLR}' : repeat the last 2 actions but holding in 2 variables, after, is calculated the percentage of used RAM. (USED RAM * 100 / FULL RAM)                  
#     
#      sources: https://www.gnu.org/software/gawk/manual/gawk.html
#               https://likegeeks.com/awk-command/
#               
# */

# 5) The current available memory on your server and its utilization rate as a percentage:
FULLD=$(df -Bg | grep /dev/ | grep -v /boot | awk '{FULLD += $2} END {print FULLD}')
USEDD=$(df -Bg | grep /dev/ | grep -v /boot | awk '{USEDD += $3} END {print USEDD}')
PORUD=$(df -Bg | grep /dev/ | grep -v /boot | awk '{FULLD += $2} {USEDD += $3}  END {printf("%d"), (USEDD*100)/FULLD }')

# /* 
#     
#                                                                     df -Bg : report the amount of memory used in disk, in gigabytes.
#                                                                        -Bg : set the output measurement unit of df. (g - GB).
#                                                                 grep /dev/ : show just the line representing the mount point /dev/ which represents the full disk.
#                                                              grep -v /boot : remove the line containing the mount point /boot information.
#                                      awk '{FULLD += $2} END {print FULLD}' : Column 2 represents the full size of the partition. So it is summing all disk size of lines containing /dev.
#  awk '{FULLD += $2} {USEDD += $3}  END {printf("%d"), (USEDD*100)/FULLD }' : Do the last action 2 times, again for 2 columns and also for 3 columns which represents the memory used, after with both values the use percentage is calculated. (USED DISK SPACE * 100 / FULL DISK SPACE).                  
#     
#      sources: https://linuxcommand.org/lc3_man_pages/df1.html
#               
# */

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
