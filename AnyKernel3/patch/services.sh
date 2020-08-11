#!/vendor/bin/sh
echo 1G > /sys/block/zram0/disksize
mkswap /dev/block/zram0
swapon /dev/block/zram0
echo 80 > /proc/sys/vm/swappiness
echo 0 > /proc/sys/vm/page-cluster
echo $(nproc) > /sys/block/zram0/max_comp_streams