#!/vendor/bin/sh
if [[ -d "/sys/block/zram0" ]]
then
    memsize=`cat /proc/meminfo | grep "MemTotal" | awk '{print $2}'`
    halfmemsize=`echo "$memsize/2" | bc`

    swapoff /dev/block/zram0
    echo 1 > /sys/block/zram0/reset
    echo ${halfmemsize}KB > /sys/block/zram0/disksize
    mkswap /dev/block/zram0
    swapon /dev/block/zram0
    echo 80 > /proc/sys/vm/swappiness
    echo 0 > /proc/sys/vm/page-cluster
    echo $(nproc) > /sys/block/zram0/max_comp_streams
fi