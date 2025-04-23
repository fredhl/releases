#!/bin/sh
#app_name=$1         # start.sh 的输入参数，dev_name
#dev_type=${app_name:1:1}"u"    # 根据app_name判断设备是au/eu/ru
cd $(dirname $0)    # $0: 当前start.sh的目录，进入当前目录
#cd ../$dev_type     # 进入当前程序的au/eu/ru目录
dir=$(pwd)
#echo $app_name
#echo $dev_type
echo $dir           # 打印当前dev_name、au/eu/ru、当前目录
filename=$(ls)
for var in $(ls)    # 判断au/eu/ru目录中所有的文件
do
    echo $var
    if [[ $var == p7_system_wrapper*.bin ]]   # 查找对应的FPGA文件 dev_name.rbf
    then
    	cp -rf $dir/$var /mnt/ram/p7_system_wrapper.bin
    fi
    if [[ $var == zynq*.d ]]     # 查找对应的应用程序文件
    then
    	cp -rf $dir/$var /mnt/ram/zynq.d
    fi
done

chmod -R 777 /mnt/*

rc=0
# 监视dev_name程序的函数
proc_watch()
{
    while [ $rc -lt 3 ]  # 最多启动3次
    do
        # 使用ps命令查看是否有dev_name的进程
        ps aux | grep zynq.d | grep -v "grep zynq.d" | grep -v $0 > /dev/null 2>&1
        if [ $? -ne 0 ]  
        then  # 没有发现dev_name进程 
            echo "zynq.d stop"
            if [ $rc -eq 0 ]
            then  # 记录第一次app_name停止运行的时间time1
                time1=$(date +%s%N|cut -c1-13)
            fi
            rc=$(($rc+1))
            if [ $rc -lt 3 ]
            then # 启动次数＜3，则在/ramDisk中直接启动app_name
                /mnt/ram/zynq.d &
            else  # 当启动次数>=3的时候，记录app_name,停止运行的时间time2
                reboot
            fi
        fi
        sleep 2    
    done    
}

#等待3s,如果有按键输入不允许控制程序
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



   