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

upgrade_compressed=upgrade.tar.gz
upgrade_uncompressed=upgrade
upgrade_packets=/mnt/flash/${upgrade_compressed}
upgrade_root=/mnt/ram
skip_copy_file=uImage
flash_path=/mnt/flash
kernel_part=/dev/mtd1

upgrade(){
    if [ -f $upgrade_packets ] ; then
    		mkdir -p ${upgrade_root}
            mv $upgrade_packets $upgrade_root
            sync
            tar xvzf  ${upgrade_root}/${upgrade_compressed} -C ${upgrade_root}
            rm -rf ${upgrade_root}/${upgrade_compressed}
            cd ${upgrade_root}/${upgrade_uncompressed} && cp -rf `ls ${upgrade_root}/${upgrade_uncompressed} | grep -v ${skip_copy_file} | xargs` ${flash_path}
            if [ -f ${upgrade_root}/${upgrade_uncompressed}/${skip_copy_file} ] ; then
                    flashcp -v ${upgrade_root}/${upgrade_uncompressed}/${skip_copy_file} ${kernel_part}
                    sync
                    reboot
            fi
    fi
}

config_ppp(){
	mkdir -p /var/spool/cron/crontabs;
	mkdir -p /var/lock
	mkdir -p /var/run
	# mkdir -p /mnt/flash/log
	mkdir -p /etc/ppp
}

reboot_proc(){
	local time=$(( 24*3600*2 )) #定时重启功能
	while `sleep $time`
	do
		reboot
	done
}

upgrade
# reboot_proc &
config_ppp
ifconfig eth0 down
ifconfig eth0 hw ether $MAC0:$MAC1:$MAC2:$MAC3:$MAC4:$MAC5
ifconfig eth0 up
sleep 2
ifconfig eth0:1 10.1.68.168 netmask 255.255.0.0
ifconfig eth1 192.168.10.1
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
# link from ru 20.2
ifconfig eth1:1 192.168.20.1 netmask 255.255.255.0
ip ro append 192.168.98.0/24 via 192.168.20.2
sleep 2

cp /mnt/flash/fun /usr/sbin
mkdir -p /var/log/boa
/mnt/flash/boa/boa -c /mnt/flash/boa
echo 	start.sh Start ...
/mnt/flash/start.sh
