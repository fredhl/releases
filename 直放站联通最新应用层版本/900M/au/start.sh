#!/bin/sh
#app_name=$1         # start.sh �����������dev_name
#dev_type=${app_name:1:1}"u"    # ����app_name�ж��豸��au/eu/ru
cd $(dirname $0)    # $0: ��ǰstart.sh��Ŀ¼�����뵱ǰĿ¼
#cd ../$dev_type     # ���뵱ǰ�����au/eu/ruĿ¼
dir=$(pwd)
#echo $app_name
#echo $dev_type
echo $dir           # ��ӡ��ǰdev_name��au/eu/ru����ǰĿ¼
filename=$(ls)
for var in $(ls)    # �ж�au/eu/ruĿ¼�����е��ļ�
do
    echo $var
    if [[ $var == p7_system_wrapper*.bin ]]   # ���Ҷ�Ӧ��FPGA�ļ� dev_name.rbf
    then
    	cp -rf $dir/$var /mnt/ram/p7_system_wrapper.bin
    fi
    if [[ $var == zynq*.d ]]     # ���Ҷ�Ӧ��Ӧ�ó����ļ�
    then
    	cp -rf $dir/$var /mnt/ram/zynq.d
    fi
done

chmod -R 777 /mnt/*

rc=0
# ����dev_name����ĺ���
proc_watch()
{
    while [ $rc -lt 3 ]  # �������3��
    do
        # ʹ��ps����鿴�Ƿ���dev_name�Ľ���
        ps aux | grep zynq.d | grep -v "grep zynq.d" | grep -v $0 > /dev/null 2>&1
        if [ $? -ne 0 ]  
        then  # û�з���dev_name���� 
            echo "zynq.d stop"
            if [ $rc -eq 0 ]
            then  # ��¼��һ��app_nameֹͣ���е�ʱ��time1
                time1=$(date +%s%N|cut -c1-13)
            fi
            rc=$(($rc+1))
            if [ $rc -lt 3 ]
            then # ����������3������/ramDisk��ֱ������app_name
                /mnt/ram/zynq.d &
            else  # ����������>=3��ʱ�򣬼�¼app_name,ֹͣ���е�ʱ��time2
                reboot
            fi
        fi
        sleep 2    
    done    
}

#�ȴ�3s,����а������벻������Ƴ���
read -t 3 -p "Do you want run init shell [y/n]?:" answer
case $answer in
    N|n)
    ;;
    *)
    echo "******Run App******"  
    /mnt/ram/zynq.d &
    sleep 1
    proc_watch &
    ;;
esac



   