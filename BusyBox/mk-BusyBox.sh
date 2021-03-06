#!/usr/bin/env bash

Make="make -j$(cat /proc/cpuinfo | grep "cpu cores" | wc -l)"

if [ ! -f ../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_BusyBoxVNumber="$(grep -i ^AtomLinux_BusyBoxVNumber ../VariableSetting | cut -f2 -d'=')"
AtomLinux_InitramfsLinuxAppDirName="$(grep -i ^AtomLinux_InitramfsLinuxAppDirName ../VariableSetting | cut -f2 -d'=')"
AtomLinux_LinuxSoftwareDirName="$(grep -i ^AtomLinux_LinuxSoftwareDirName ../VariableSetting | cut -f2 -d'=')"
AtomLinux_InitramfsLinuxAppFontDirName="$(grep -i ^AtomLinux_InitramfsLinuxAppFontDirName ../VariableSetting | cut -f2 -d'=')"
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ../VariableSetting | cut -f2 -d'=')"
AtomLinux_DownloadURL="$(grep -i ^AtomLinux_BusyBoxURL ../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

OBJ_PROJECT=busybox
FILENAME_Prefix=busybox-$AtomLinux_BusyBoxVNumber
FILENAME=${FILENAME_Prefix}.tar.bz2
FILENAME_DIR=${FILENAME_Prefix}

#Clean
function clean_busybox()
{
    rm -f ./mk-Bale-customize.sh
    rm -rf ./initramfs
    rm -rf ./*_install
    rm -rf ./examples
    rm -rf ./iso_tmp
    rm -rf ./$AtomLinux_InitramfsLinuxAppDirName
    rm -rf ./$AtomLinux_InitramfsLinuxAppFontDirName
    rm -rf ./$AtomLinux_LinuxSoftwareDirName
    #MyConfig
    rm -f ./MyConfig/etc/profile.user
    rm -rf ./MyConfig/lib
    rm -rf ./MyConfig/lib64
    rm -rf ./MyConfig/usr
    #MyConfig

    rm -rf ${OBJ_PROJECT}-tmp
}

if test $1 && [ $1 = "clean" ]; then
    clean_busybox
    echo "busybox clean ok!"
    exit
fi
#Clean

#Download Source Code
if [ ! -f ./${FILENAME} ]; then
    #Check if necessary tools are installed
    if [ -z $(which wget) ]; then
        echo "wget is not installed."
        exit 1
    fi
    #Check if necessary tools are installed
    wget ${AtomLinux_DownloadURL}${FILENAME}
    if [ ! $? -eq 0 ]; then
        echo "Error: Download busybox ."
        exit 1
    fi
    #Check if it is downloaded successfully
    if [ ! -f ./${FILENAME} ]; then
        echo "Error: Download busybox ."
        exit 1
    fi
fi
#Download Source Code

#Platform
ARCH=x86
if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    ARCH=x86_64
fi
#Platform

ROOTFS_NAME=rootfs

clean_busybox
mkdir ${OBJ_PROJECT}-tmp
tar -xjvf ${FILENAME} -C ./${OBJ_PROJECT}-tmp/
#Check Decompression
if [ ! $? -eq 0 ]; then
    echo "Error: Decompression busybox ."
    exit 1
fi
#Check Decompression

#mkdir
mkdir $AtomLinux_LinuxSoftwareDirName
mkdir $AtomLinux_InitramfsLinuxAppDirName
mkdir $AtomLinux_InitramfsLinuxAppFontDirName
#mkdir

cd ./${OBJ_PROJECT}-tmp/${FILENAME_DIR}

#Patches
if [ -d ../../Patches ]; then
    for file in $(ls ../../Patches);
    do
        echo -e "\033[31m$file\033[0m"
        patch -p1 < ../../Patches/$file
        #Check patch
        if [ ! $? -eq 0 ]; then
            echo "Error: patch (busybox) ."
            exit 1
        fi
        #Check patch
    done
fi
#Patches

make defconfig
#Check make defconfig
if [ ! $? -eq 0 ]; then
    echo "Error: make defconfig (busybox) ."
    exit 1
fi
#Check make defconfig

#make
if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    echo | $Make
else
    if [ $(getconf LONG_BIT) = '64' ]; then
        echo | $Make CC="gcc -m32" CXX="g++ -m32"
    else
        echo | $Make
    fi
fi
#make

#Check make
if [ ! $? -eq 0 ]; then
    echo "Error: make (busybox) ."
    exit 1
fi
#Check make

#make install
if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    make install
else
    if [ $(getconf LONG_BIT) = '64' ]; then
        make CC="gcc -m32" CXX="g++ -m32" install
    else
        make install
    fi
fi
#make install

#Check make install
if [ ! $? -eq 0 ]; then
    echo "Error: make install (busybox) ."
    exit 1
fi
#Check make install

#Copy busybox examples
rm -rf ../../examples
cp -rv ./examples ../../
#Copy busybox examples

rm -rf ../../${ARCH}_install
mv ./_install ../../${ARCH}_install
cd ../../
rm -rf ${OBJ_PROJECT}-tmp

echo "Complete."
