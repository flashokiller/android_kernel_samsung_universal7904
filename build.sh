#!/bin/bash
#
# Copyright © 2020, Samar Vispute "SamarV-121" <samarvispute121@gmail.com>
#
# Custom build script
#
# This software is licensed under the terms of the GNU General Public
# License version 2, as published by the Free Software Foundation, and
# may be copied, distributed, and modified under those terms.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 gcc
export KBUILD_BUILD_USER="SamarV-121"
export ARCH=arm64
export CROSS_COMPILE=$(pwd)/gcc/bin/aarch64-linux-android-
git config --global user.name "SamarV-121" && git config --global user.email "samarvispute121@gmail.com"

## Custom Roms (any other than OneUI)
# Generic MTP driver
generic_mtp() {
curl https://github.com/SamarV-121/android_kernel_samsung_universal7904/commit/dcea56dd7942305897e63ec57ede912d4f3b500b.patch | git am
}
# Hardcode SELinux to Permissive
permissive() { 
curl https://github.com/SamarV-121/android_kernel_samsung_universal7904/commit/d32e21c9d25c2ce0f7cd9d664b073c99e9267ec9.patch | git am
}

## OneUI
# Samsung MTP driver
samsung_mtp() {
curl https://github.com/SamarV-121/android_kernel_samsung_universal7904/commit/9c575e78b54380f607b003d1ce712d94327ac9e4.patch | git am
}
# Enforce SELinux
enforcing() {
curl https://github.com/SamarV-121/android_kernel_samsung_universal7904/commit/b6d4e2b03b52f81da94420b8ca15a6f3db22aaee.patch | git am
}

zipname () {
ZIPNAME=FuseKernel-test-$(date "+%Y%m%d-%H%M")-$DEVICE.zip
}

zipname_oneui () {
ZIPNAME=FuseKernel-test-oneuiv2-$(date "+%Y%m%d-%H%M")-$DEVICE.zip
}

build () {
echo -e "$blue***********************************************"
echo "        Compiling Fuse kernel for $DEVICE         "
echo -e "$blue***********************************************"
curl -s -X POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage -d text="Started Compiling Kernel for $DEVICE" -d chat_id=$TELEGRAM_CHAT > /dev/null
BUILD_START=$(date +"%s")
make ${DEVICE}_defconfig O=out
make O=out -j$(nproc)
BUILD_END=$(date +"%s")
BUILD_DIFF=$((BUILD_END - BUILD_START))
echo -e "$yellow Build completed successfully in $((BUILD_DIFF / 60)) minute(s)."
}

make_zip () {
echo -e "$blue***********************************************"
echo -e "     Making flashable zip         "
echo -e "$blue***********************************************"
cp -f out/arch/$ARCH/boot/Image AnyKernel3/Image
cd AnyKernel3
zip -r9 $ZIPNAME META-INF tools anykernel.sh Image patch
cd ..
}

upload () {
echo -e "$blue***********************************************"
echo -e "     Uploading         "
echo -e "$blue***********************************************"
curl -F "file=@AnyKernel3/$ZIPNAME" https://api.bayfiles.com/upload | awk 'BEGIN { FS="https://"; } { print $2; }' | sed 's|","short":"||' | sed 's|^|https://|' > ~/$DEVICE
}

lenk () {
echo -e "$cyan Link: $(<~/$DEVICE)"
curl -s -X POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage -d text="Build completed successfully in $((BUILD_DIFF / 60)) minute(s)
Filename: $ZIPNAME
Download: $(<~/$DEVICE)" -d chat_id=$TELEGRAM_CHAT > /dev/null
curl -s -F "chat_id=$TELEGRAM_CHAT" -F "sticker=CAADBQAD8gADLG6EE1T3chaNrvilFgQ" https://api.telegram.org/bot"$TELEGRAM_TOKEN"/sendSticker > /dev/null
}

lenk_oneui () {
echo -e "$cyan Link for OneUI: $(<~/$DEVICE)"
curl -s -X POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage -d text="For OneUI-2.0:
Filename: $ZIPNAME
Download: $(<~/$DEVICE)" -d chat_id=$TELEGRAM_CHAT > /dev/null
curl -s -F "chat_id=$TELEGRAM_CHAT" -F "sticker=CAADBQAD8gADLG6EE1T3chaNrvilFgQ" https://api.telegram.org/bot"$TELEGRAM_TOKEN"/sendSticker > /dev/null
}

DEVICE=m20lte
permissive
zipname
echo -e "$blue***********************************************"
echo "        Compiling Fuse kernel for $DEVICE         "
echo -e "$blue***********************************************"
curl -s -X POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage -d text="Started Compiling Kernel for $DEVICE" -d chat_id=$TELEGRAM_CHAT > /dev/null
BUILD_START=$(date +"%s")
make ${DEVICE}_defconfig O=out
make O=out -j$(nproc) 2>&1 | tee build.log
grep "error:" build.log > error
BUILD_END=$(date +"%s")
BUILD_DIFF=$((BUILD_END - BUILD_START))
if [ -e "out/arch/$ARCH/boot/Image" ]; then
echo -e "$yellow Build completed successfully in $((BUILD_DIFF / 60)) minute(s)"
make_zip
upload
lenk
else
echo -e "$red Kernel Compilation failed "
curl -s -X POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage -d text="Build failed in $((BUILD_DIFF / 60)) minute(s)" -d chat_id=$TELEGRAM_CHAT > /dev/null
curl -s -X POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage -d text="Here is the error:
$(<error)" -d chat_id=$TELEGRAM_CHAT > /dev/null
curl -s -F "chat_id=$TELEGRAM_CHAT" -F "sticker=CAADBQAD8gADLG6EE1T3chaNrvilFgQ" https://api.telegram.org/bot"$TELEGRAM_TOKEN"/sendSticker > /dev/null
exit 1
fi

enforcing
samsung_mtp
zipname_oneui
build
make_zip
upload
lenk_oneui

DEVICE=m30lte
generic_mtp
permissive
zipname
build
make_zip
upload
lenk

enforcing
samsung_mtp
zipname_oneui
build
make_zip
upload
lenk_oneui

DEVICE=a30dd
generic_mtp
permissive
zipname
build
make_zip
upload
lenk

enforcing
samsung_mtp
zipname
build
make_zip
upload
lenk_oneui

DEVICE=a40dd
generic_mtp
permissive
zipname
build
make_zip
upload
lenk

enforcing
samsung_mtp
zipname_oneui
build
make_zip
upload
lenk_oneui
