#!/bin/sh
echo 	init.sh Start ...
chmod 777 /mnt/flash -R
echo "********** Setup the MACaddress  ********"
MACADDRESS=/mnt/flash/config/mac.txt
MAC0="00"
if [ -s $MACADDRESS ]; then
	MAC1=$(cut -b1-2  $MACADDRESS)
	MAC2=$(cut -b3-4  $MACADDRESS)
	MAC3=$(cut -b5-6  $MACADDRESS)
	MAC4=$(cut -b7-8  $MACADDRESS)
	MAC5=$(cut -b9-10 $MACADDRESS)
else
	hexdump -e '"%02x"' -n 5 /dev/urandom > $MACADDRESS
	echo "Setup the MACaddress by /dev/urandom for the first time!"
	MAC1=$(cut -b1-2  $MACADDRESS)
	MAC2=$(cut -b3-4  $MACADDRESS)
	MAC3=$(cut -b5-6  $MACADDRESS)
	MAC4=$(cut -b7-8  $MACADDRESS)
	MAC5=$(cut -b9-10 $MACADDRESS)
fi
ifconfig eth0 192.168.98.98 netmask 255.255.255.0
ifconfig eth0:1 10.1.68.188 netmask 255.255.0.0
ifconfig eth1 down
ifconfig eth1 hw ether $MAC0:$MAC1:$MAC2:$MAC3:$MAC4:$MAC5
ifconfig eth1 up
echo 1 > /proc/sys/net/ipv4/ip_forward


if [ -f /mnt/flash/libstdc\+\+.so.6.0.19 ]; then
	if [ -f /lib/libstdc++.so.6 ];then
		echo "lib file already exists"
	else
		ln -s /mnt/flash/libstdc\+\+.so.6.0.19 /lib/libstdc++.so.6
	fi
else
	echo " ** lib file not exists, can not gdb **"
fi

cp /mnt/flash/fun /usr/sbin
mkdir -p /var/log/boa
mkdir -p /var/spool/cron/crontabs
/mnt/flash/boa/boa -c /mnt/flash/boa
echo 	start.sh Start ...
/mnt/flash/start.sh
