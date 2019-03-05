#!/usr/bin/env bash

if [ ! -f ../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_GraphicsLibrary="$(grep -i ^AtomLinux_GraphicsLibrary ../VariableSetting | cut -f2 -d'=')"
AtomLinux_InitramfsLinuxAppFontDirName="$(grep -i ^AtomLinux_InitramfsLinuxAppFontDirName ../VariableSetting | cut -f2 -d'=')"
AtomLinux_InitramfsLinuxAppDirName="$(grep -i ^AtomLinux_InitramfsLinuxAppDirName ../VariableSetting | cut -f2 -d'=')"
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ../VariableSetting | cut -f2 -d'=')"
AtomLinux_UsingIconvLib="$(grep -i ^AtomLinux_UsingIconvLib ../VariableSetting | cut -f2 -d'=')"
AtomLinux_UsingMdadm="$(grep -i ^AtomLinux_UsingMdadm ../VariableSetting | cut -f2 -d'=')"
AtomLinux_UsingDislocker="$(grep -i ^AtomLinux_UsingDislocker ../VariableSetting | cut -f2 -d'=')"
AtomLinux_UsingWeston="$(grep -i ^AtomLinux_UsingWeston ../VariableSetting | cut -f2 -d'=')"
AtomLinux_NetworkSupport="$(grep -i ^AtomLinux_NetworkSupport ../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

#Platform
ARCH=x86
if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    ARCH=x86_64
fi
#Platform

./CopyLib.sh
#Check
if [ ! $? -eq 0 ]; then
    echo "Error: CopyLib.sh ."
    exit 1
fi
#Check

ROOTFS_NAME=rootfs
RAMDISK_NAME=initramfs
rm -rf ${RAMDISK_NAME}
mkdir ./${ARCH}-${ROOTFS_NAME}
cd ./${ARCH}-${ROOTFS_NAME}/
cp -rv ../${ARCH}_install/* ./

mv linuxrc init
mkdir dev etc home lib proc root sys tmp var run

#GraphicsLibrary
if [ ${AtomLinux_GraphicsLibrary} = "Qt" ]; then
    mkdir -p ./usr/lib/
    mkdir -p ./usr/fonts/

    cp -rv ../../Qt/${ARCH}_release_Emb/lib/libQtCore.so* ./usr/lib/
    cp -rv ../../Qt/${ARCH}_release_Emb/lib/libQtGui.so* ./usr/lib/
    cp -rv ../../Qt/${ARCH}_release_Emb/lib/libQtNetwork.so* ./usr/lib/
    cp -rv ../../Qt/${ARCH}_release_Emb/lib/fonts/fixed_120_50.qpf ./usr/fonts/
    cp -rv ../$AtomLinux_InitramfsLinuxAppFontDirName/* ./usr/fonts/
elif [ ${AtomLinux_GraphicsLibrary} = "Qt5" ]; then
    mkdir -p ./usr/lib/
    mkdir -p ./usr/qt5/fonts/

    cp -rv ../../Qt/${ARCH}_qt5_release/lib/libQt5Core.so* ./usr/lib/
    cp -rv ../../Qt/${ARCH}_qt5_release/lib/libQt5Gui.so* ./usr/lib/
    cp -rv ../../Qt/${ARCH}_qt5_release/lib/libQt5Widgets.so* ./usr/lib/
    cp -rv ../../Qt/${ARCH}_qt5_release/plugins ./usr/qt5
    cp -rv ../$AtomLinux_InitramfsLinuxAppFontDirName/* ./usr/qt5/fonts/
elif [ ${AtomLinux_GraphicsLibrary} = "Ncurses" ]; then
    mkdir -p ./usr/lib/
    mkdir -p ./usr/share/terminfo/

    cp -rv ../../Ncurses/${ARCH}-ncurses/lib/libformw.so* ./usr/lib/
    cp -rv ../../Ncurses/${ARCH}-ncurses/lib/libmenuw.so* ./usr/lib/
    cp -rv ../../Ncurses/${ARCH}-ncurses/lib/libncursesw.so* ./usr/lib/
    cp -rv ../../Ncurses/${ARCH}-ncurses/lib/libpanelw.so* ./usr/lib/
    cp -rRv ../../Ncurses/${ARCH}-ncurses/share/tabset ./usr/share/
    cp -rRv ../../Ncurses/${ARCH}-ncurses/share/terminfo/l ./usr/share/terminfo/
    cp -rRv ../../Ncurses/${ARCH}-ncurses/share/terminfo/t ./usr/share/terminfo/
fi
#GraphicsLibrary

cp -rRv ../MyConfig/* ./

#weston
if [ ${AtomLinux_UsingWeston} = "Yes" ]; then
    cp -rRv ../../Utils/weston/${ARCH}-weston/* ./
    #mkdir -p ./etc/xdg/weston/
    #cp ../../Utils/weston/weston.ini ./etc/xdg/weston/
fi
#weston

#iconv Support
if [ ${AtomLinux_UsingIconvLib} = "Yes" ]; then
    mkdir -p ./usr/lib/
    cp -v ../../Lib/libiconv/${ARCH}-libiconv/usr/lib/preloadable_libiconv.so ./usr/lib/
fi
#iconv Support

#RAID Support
if [ ${AtomLinux_UsingMdadm} = "Yes" ]; then
    mkdir -p ./usr/sbin/
    cp -v ../../Utils/mdadm/${ARCH}-mdadm/sbin/mdadm ./usr/sbin/
fi
#RAID Support

#BitLocker Support
if [ ${AtomLinux_UsingDislocker} = "Yes" ]; then
    mkdir -p ./usr/lib/
    mkdir -p ./usr/bin/
    cp -rv ../../Utils/dislocker/${ARCH}-dislocker/usr/local/* ./usr/
fi
#BitLocker Support

#Copy udhcpc script
if [ ${AtomLinux_NetworkSupport} = "Yes" ]; then
    if [ -f ../examples/udhcp/simple.script ]; then
        mkdir -p ./usr/share/udhcpc/
        cp -v ../examples/udhcp/simple.script ./usr/share/udhcpc/default.script
    else
        echo "Error: simple.script file does not exist ."
        exit 1
    fi
fi
#Copy udhcpc script

mkdir $AtomLinux_InitramfsLinuxAppDirName

if test $1 && [ $1 = "cd" ]; then
    if [ -f ../mk-Bale-customize.sh ]; then
        ../mk-Bale-customize.sh
    fi
    echo "cpio For CD"
else
    if [ $(ls ../$AtomLinux_InitramfsLinuxAppDirName/ -A $1|wc -w | awk '{print int($0)}') -gt 0 ]; then
        cp -rv ../$AtomLinux_InitramfsLinuxAppDirName/* ./$AtomLinux_InitramfsLinuxAppDirName/
    fi
fi

if [ ${AtomLinux_GraphicsLibrary} = "Null" ]; then
    rm -rf ./$AtomLinux_InitramfsLinuxAppDirName
fi

#Create Version File
strCurrentDateTime=`date "+%Y-%m-%d %H:%M:%S"`
echo "OS Build Time:"${strCurrentDateTime} >> ./etc/version
strGitRevParse=`git rev-parse --short HEAD`
echo "Git Commit ID:"${strGitRevParse} >> ./etc/version
#Create Version File

#find . | cpio -o -H newc | gzip > ../${RAMDISK_NAME}
#find . | cpio -o -H newc | lzma -9 -v > ../${RAMDISK_NAME}
find . | cpio -R root:root -H newc -o | xz -9 -v --check=none > ../${RAMDISK_NAME}
cd ..
rm -rf ${ARCH}-${ROOTFS_NAME}

echo "Complete."
