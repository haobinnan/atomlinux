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

# CD
AtomLinux_SoftwareName="$(grep -i ^AtomLinux_SoftwareName ../VariableSetting | cut -f2 -d'=')"
AtomLinux_LinuxSoftwareDirName="$(grep -i ^AtomLinux_LinuxSoftwareDirName ../VariableSetting | cut -f2 -d'=')"
# CD
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

Copy_libiconv="no"

#GraphicsLibrary
if [ ${AtomLinux_GraphicsLibrary} = "Qt" ]; then
    mkdir -p ./qt/fonts/
    mkdir -p ./qt/lib/
    cp -rv ../../Qt/${ARCH}_release_Emb/lib/libQtCore.so* ./qt/lib/
    cp -rv ../../Qt/${ARCH}_release_Emb/lib/libQtGui.so* ./qt/lib/
    cp -rv ../../Qt/${ARCH}_release_Emb/lib/libQtNetwork.so* ./qt/lib/
    cp -rv ../../Qt/${ARCH}_release_Emb/lib/fonts/fixed_120_50.qpf ./qt/fonts/
    cp -rv ../$AtomLinux_InitramfsLinuxAppFontDirName/* ./qt/fonts/

    Copy_libiconv="yes"
elif [ ${AtomLinux_GraphicsLibrary} = "Qt5" ]; then
    mkdir -p ./qt5/fonts/
    mkdir -p ./qt5/lib/
    cp -rv ../../Qt/${ARCH}_release/lib/libQt5Core.so* ./qt5/lib/
    cp -rv ../../Qt/${ARCH}_release/lib/libQt5Gui.so* ./qt5/lib/
    cp -rv ../../Qt/${ARCH}_release/lib/libQt5Widgets.so* ./qt5/lib/
    cp -rv ../../Qt/${ARCH}_release/plugins ./qt5
    cp -rv ../$AtomLinux_InitramfsLinuxAppFontDirName/* ./qt5/fonts/

    Copy_libiconv="yes"
elif [ ${AtomLinux_GraphicsLibrary} = "Ncurses" ]; then
    mkdir -p ./usr/share/terminfo/
    cp -rv ../../Ncurses/${ARCH}-ncurses/lib/libformw.so* ./lib/
    cp -rv ../../Ncurses/${ARCH}-ncurses/lib/libmenuw.so* ./lib/
    cp -rv ../../Ncurses/${ARCH}-ncurses/lib/libncursesw.so* ./lib/
    cp -rv ../../Ncurses/${ARCH}-ncurses/lib/libpanelw.so* ./lib/
    cp -rRv ../../Ncurses/${ARCH}-ncurses/share/tabset ./usr/share/
    cp -rRv ../../Ncurses/${ARCH}-ncurses/share/terminfo/l ./usr/share/terminfo/
    cp -rRv ../../Ncurses/${ARCH}-ncurses/share/terminfo/t ./usr/share/terminfo/

    Copy_libiconv="yes"
fi
#GraphicsLibrary

cp -rRv ../MyConfig/* ./
if [ ${Copy_libiconv} = "yes" ]; then
    cp -v ../../Lib/libiconv/${ARCH}-libiconv/preloadable_libiconv.so ./lib/
else
    sed -i '/preloadable_libiconv.so/d' ./etc/profile
fi

#RAID Support
cp -v ../../Utils/mdadm/${ARCH}-mdadm/mdadm ./sbin/
cp -v ../../Utils/mdadm/${ARCH}-mdadm/mdmon ./sbin/
#RAID Support

mkdir $AtomLinux_InitramfsLinuxAppDirName

if test $1 && [ $1 = "cd" ]; then
    sed -i '/.\/SearchApp/d' ./etc/profile
    sed -i 's/TransferCommandLine/'${AtomLinux_SoftwareName}' -qws/' ./etc/profile

    cp -rv ../$AtomLinux_LinuxSoftwareDirName/* ./$AtomLinux_InitramfsLinuxAppDirName/

    echo "[SectionInfo]\r
FromBootMark = \"CDR\"\r">>./${AtomLinux_InitramfsLinuxAppDirName}/Info.ini

    echo "cpio For CD"
else
    if [ $(ls ../$AtomLinux_InitramfsLinuxAppDirName/ -A $1|wc -w | awk '{print int($0)}') -gt 0 ]; then
        cp -rv ../$AtomLinux_InitramfsLinuxAppDirName/* ./$AtomLinux_InitramfsLinuxAppDirName/
    fi
fi

if [ ${AtomLinux_GraphicsLibrary} = "Null" ]; then
    rm -rf ./$AtomLinux_InitramfsLinuxAppDirName
fi

#find . | cpio -o -H newc | gzip > ../${RAMDISK_NAME}
#find . | cpio -o -H newc | lzma -9 -v > ../${RAMDISK_NAME}
find . | cpio -R root:root -H newc -o | xz -9 -v --check=none > ../${RAMDISK_NAME}
cd ..
rm -rf ${ARCH}-${ROOTFS_NAME}

echo "Complete."
