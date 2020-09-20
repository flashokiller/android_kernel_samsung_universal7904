# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers
# SamarV-121 "samarvispute121@gmail.com"

## AnyKernel setup
# begin properties
properties() { '
kernel.string=FuseKernel by SamarV-121
do.devicecheck=0
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=10-11
'; } # end properties

# shell variables
# block=;
# is_slot_device=0;
ramdisk_compression=auto;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

## AnyKernel install
dump_boot;

# Remount system and vendor
mount /system_root;
mount -o rw,remount /vendor;

# Find device/rom and copy kernel
device_name=$(grep ro.product.vendor.device /vendor/build.prop | sed "s/.*=//g");
if grep PDA /system_root/system/build.prop; then
cp -f $home/Image_${device_name}_oneui $home/Image;
else
cp -f $home/Image_$device_name $home/Image;
fi

# Patch vendor
restore_file /vendor/build.prop;
backup_file /vendor/build.prop;
append_file /vendor/build.prop "" build.prop;
cp -f $home/patch/services.rc /vendor/etc/init;
cp -f $home/patch/services.sh /vendor/bin;
chmod +x /vendor/bin/services.sh;

write_boot;
## end install
