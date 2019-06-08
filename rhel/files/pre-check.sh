#!/bin/bash
#Before patching

LOG_FILE=/tmp/patching-data/prepatch-`uname -n`
LOG=$LOG_FILE

[[ ! -d /tmp/patching-data ]] && mkdir /tmp/patching-data

(
echo " "
echo "Capture PRE reboot for Server `uname -n` ON `date`"
echo "--------------------------------------------------------------- "
echo " "
echo  "#########  UPTIME STATUS ######## "
uptime
echo " "

echo "####### RELEASE INFO ########"
uname -a
cat /etc/os-release
echo " "

echo "########## CPU INFO ##############"
cat /proc/cpuinfo |egrep -i 'processor|name|MHz|cores'
echo " "

echo "########## MEMORY INFO ##############"
free -g
echo " "

echo "######### DISK & FILESYSTEM CONFIG INFO ###########"
df -hTP
echo " "

echo "######### Number of mounted filesystems ###########"
echo "NumberofMounts:`df -hTP | wc -l`"  | tee $LOG-mount
echo " "

echo "######### capture sysctl output ###########"
sysctl -a
echo " "

echo "########### /ETC/FSTAB Entry ###########"
cat /etc/fstab
echo " "

echo "########### NETWORK INFORMATION ##########"
/sbin/ifconfig -a
echo " "

echo " ########### VIP DETAILS ###########"
/sbin/ip addr show
echo " "

echo " ########### LINK STATUS ###########"
for i in `/sbin/ifconfig |grep eth |awk '{print $1}'`
do
echo $i
echo "-----"
ethtool $i
done
echo " "

echo "########### ROUTING TABLE ###########"
netstat -nr
echo " "
route
echo " "
echo "######### Number of route ###########"
echo "`route -n | grep -v -i ^"[a-Z]" | sort -nr`" | tee $LOG-route
echo " "

echo "########### ntp config  ###########"
cat /etc/ntp.conf |grep -v "#"|sed '/^$/d'
echo " "

echo "##########DNS INFO ###########"
cat /etc/resolv.conf
echo  " "

echo "########## /etc/hosts info ###########"
cat /etc/hosts
echo  " "

echo "########## crontabe info ###########"
crontab -l
echo  " "

echo "########## IP Tables info ###########"
iptables -L
echo  " "

echo "########## Disk details info ###########"
echo "########## PV details info ###########"
pvs
echo  " "

echo "########## VG details info ###########"
vgs
echo  " "

echo "########## LV details info ###########"
lvs
echo  " "

echo "########## Oracle DB status ###########"
ps -ef | grep -i pmon
echo  " "

echo "########## kern ##########"
uname -r
echo  " "

echo "########## print running service ###########"
service --status-all  | grep running
echo  " "

echo "########## mount output ###########"
mount
echo  " "

)> $LOG  2>&1

echo " Output saved in $LOG "

