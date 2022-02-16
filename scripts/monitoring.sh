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

# /* 
#     What is 'utilization rate of processor'? 
#     Formula:  1 - (I/O Time of a processor, so time that CPU wait a proccess Input or Output) ^ Number of processes. 
#     "Represents the time that a process is being processed by CPU."  
#     
#                            top -bn1 : Outputs in screen all processors being executed now, in a mode that can be easily piped for others commands. 
#                                 top : Display all processors being executed in a mini processes monitor program, which isn't so flexible with PIPE etc. The important column to this script is x and y because they represent x and y.
#                                  -b : Display the top result in batch mode, like a cat, so this result can be easily piped and receibe others commands.
#                                 -n1 : Stop the processes refresh after 1 time refreshed.
#                            grep Cpu : display just one line in this top result, which represents some statistics about CPU.
#                           cut -c 9- : Select just the characters after digit 9 in this line, in others words, the start of this line is cutted.
#                            "0.0 us" : % of CPU used in user processes.
#                            "0.0 ni" : % of CPU used in system low priority processes.
#   awk '{printf("%.1f%%"), $1 + $3}' : Sum both values and return formatted with 2 decimal places using printf.
#     
#      sources: https://unix.stackexchange.com/questions/18918/linux-top-command-what-are-us-sy-ni-id-wa-hi-si-and-st-for-cpu-usage
#               https://stackoverflow.com/questions/26004507/what-do-top-cpu-abbreviations-mean
#               https://www.youtube.com/watch?v=KKpm9m4A3-w
#               https://techdocs.broadcom.com/us/en/ca-enterprise-software/it-operations-management/performance-management/3-5/using/performance-metrics/cpu-utilization.html#:~:text=The%20CPU%20utilization%20metric%20is,period%20selected%20for%20the%20view.&text=is%20a%20term%20applied%20to,100%20to%20obtain%20a%20percentage.
#               https://www.youtube.com/watch?v=Q9C7nW9vBV8
# */


# 7) The date and time of the last reboot:
LBOOT=$(who -b | awk '{print $3 " " $4}')

# /* 
#                      who : show who is logged.
#                       -b : show data and time of last login.
#   awk '{print $3 " " $4}': show concatenation date and time.
#     
# */

# 8) Whether LVM is active or not:
CHECK_IF_THERE_IS_LVM=$(cat /etc/fstab | grep /dev/mapper/ | wc -l)
LVMU=$( if [ ${CHECK_IF_THERE_IS_LVM} -eq 0 ]; then echo no; else echo yes; fi )

# /* 
#     
#                                                      CHECK_IF_THERE_IS_LVM : report the amount of memory used in disk, in gigabytes.
#                                                                        -Bg : set the output measurement unit of df. (g - GB).
#                                                                 grep /dev/ : show just the line representing the mount point /dev/ which represents the full disk.
#                                                              grep -v /boot : remove the line containing the mount point /boot information.
#                                      awk '{FULLD += $2} END {print FULLD}' : Column 2 represents the full size of the partition. So it is summing all disk size of lines containing /dev.
#  awk '{FULLD += $2} {USEDD += $3}  END {printf("%d"), (USEDD*100)/FULLD }' : Do the last action 2 times, again for 2 columns and also for 3 columns which represents the memory used, after with both values the use percentage is calculated. (USED DISK SPACE * 100 / FULL DISK SPACE).                  
#     
#      sources: https://linuxcommand.org/lc3_man_pages/df1.html
#               
# */

# 9) The number of active connections:
NUMBER_OF_ACTIVE_CONNECTIONS=$(netstat -t | grep ESTABLISHED | wc -l)
NTCP=$(if [ ${NUMBER_OF_ACTIVE_CONNECTIONS} -eq 0 ]; then echo 0; else echo ${NUMBER_OF_ACTIVE_CONNECTIONS} ESTABLISHED; fi)

# /* 
#                                                   netstat -t : Print network connections with details.
#                                             grep ESTABLISHED : Filter just the connections that are established.
#                                                        wc -l : Count lines of output.
#   if [ ${NUMBER_OF_ACTIVE_CONNECTIONS} -eq 0 ]; then echo 0; 
#   else echo ${NUMBER_OF_ACTIVE_CONNECTIONS} ESTABLISHED; fi  : If there's more than 0 return the amount of conections, if not, return 0.
#               
# */

# 10) The number of users using the server:
ULOG=$(users | wc -w)

# /* 
#
#         users: show logged users.
#         wc -w: count words of line, returning the correct number of logged users.
#     
# */

# 11) The IPv4 address of your server and its MAC (Media Access Control) address:
IP=$(hostname -I | awk '{ print($1) }')
MAC=$(cat /sys/class/net/*/address | head -n 1)

# /* 
#
#                     hostname -I : Display IPv4.
#             awk '{ print($1) }' : Show it.
#    cat /sys/class/net/*/address : Display MAC Address.
#                       head -n 1 : Display just the first line.
#     
# */

# 12) The number of commands executed with the sudo program:
SUDO=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

# /* 
#
#      What is 'system md'? systemd-journald is a system service that collects 
#      and stores logging data. It creates and maintains structured, indexed journals 
#      based on logging information that is received from a variety of sources
#
#     journalctl : query system md. 
#     _COMM=sudo : _COMM=<application name> To look for log messages from a specific application.
#     ep COMMAND : Print just lines that represent SUDO commands.
#          wc -l : Count amount of lines.
#     
#    source:  https://man7.org/linux/man-pages/man1/journalctl.1.html
#             https://www.howtogeek.com/499623/how-to-use-journalctl-to-read-linux-system-logs/
#
# */



##############################################################
##                       Display                            ##
##############################################################

#1 The architecture of your operating system and its kernel version. #
echo "#Archictecture: ${ARCH}"

#2 The number of physical processors. #
echo "#CPU physical: ${PCPU}"

#3 The number of virtual processors. #
echo "#vCPU: ${VCPU}"

#4 The current available RAM on your server and its utilization rate as a percentage. #
echo "#Memory Usage: ${USEDR}/${FULLR}MB (${PORUR}%)"

#5 The current available memory on your server and its utilization rate as a percentage. #
echo "#Disk Usage: ${USEDD}/${FULLD}G (${PORUD}%)"

#6 The current utilization rate of your processors as a percentage. #
echo "#CPU load: $USE_OF_CPU"

#7 The date and time of the last reboot #
echo "#Last boot: ${LBOOT}"

#8 Whether LVM is active or not. #
echo "#LVM use: $LVMU"

#9 The number of active connections. #
echo "#Connexions TCP: $NTCP"

#10 The number of users using the server #
echo "#User log: $ULOG"

#11 The IPv4 address of your server and its MAC (Media Access Control) address. #
echo "#Network: IP ${IP} (${MAC})"

#12 The number of commands executed with the sudo program. #
echo "#Sudo: $SUDO cmd"
