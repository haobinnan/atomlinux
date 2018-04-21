#!/usr/bin/env bash

Make="make -j$(cat /proc/cpuinfo | grep "cpu cores" | wc -l)"

if [ ! -f ../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_LinuxKernelVNumber="$(grep -i ^AtomLinux_LinuxKernelVNumber ../VariableSetting | cut -f2 -d'=')"
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ../VariableSetting | cut -f2 -d'=')"
AtomLinux_DownloadURL="$(grep -i ^AtomLinux_LinuxKernelURL ../VariableSetting | cut -f2 -d'=')"
AtomLinux_SecureBootSignature="$(grep -i ^AtomLinux_SecureBootSignature ../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

OBJ_PROJECT=linuxkernel
FILENAME_Prefix=linux-$AtomLinux_LinuxKernelVNumber
FILENAME=${FILENAME_Prefix}.tar.xz
FILENAME_DIR=${FILENAME_Prefix}

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
        echo "Error: Download linuxkernel ."
        exit 1
    fi
    #Check if it is downloaded successfully
    if [ ! -f ./${FILENAME} ]; then
        echo "Error: Download linuxkernel ."
        exit 1
    fi
fi
#Download Source Code

mkdir ${OBJ_PROJECT}-code-tmp

tar xvJf ./${FILENAME} -C ./${OBJ_PROJECT}-code-tmp
#Check Decompression
if [ ! $? -eq 0 ]; then
    echo "Error: Decompression linuxkernel ."
    exit 1
fi
#Check Decompression

cd ./${OBJ_PROJECT}-code-tmp/${FILENAME_DIR}

#Replace logo file
if [ -f ../../logo/my_logo.ppm ]; then
    cp -v ../../logo/my_logo.ppm ./drivers/video/logo/logo_linux_clut224.ppm

    #Change to one logo (penguin)
    sed -i 's/num_online_cpus()/1/' ./drivers/video/fbdev/core/fbmem.c
    #Change to one logo (penguin)
fi
#Replace logo file

#Secure Boot Patches

#https://github.com/vathpela/linux
if [ ${AtomLinux_SecureBootSignature} = "Yes" ]; then
    for file in $(ls ../../SecureBootPatches);
    do
        echo -e "\033[31m$file\033[0m"
        patch -p1 < ../../SecureBootPatches/$file
        #Check patch
        if [ ! $? -eq 0 ]; then
            echo "Error: patch (linuxkernel) ."
            exit 1
        fi
        #Check patch
    done
fi
#Secure Boot Patches

#function
function build()
{
    ARCH=$1
    if [ ${AtomLinux_SecureBootSignature} = "Yes" ]; then
        CONFIG_NAME=".config_"${ARCH}"_sb"
    else
        CONFIG_NAME=".config_"${ARCH}
    fi

    cp -v ../../${CONFIG_NAME} ./.config

    echo | $Make bzImage
    #Check make
    if [ ! $? -eq 0 ]; then
        echo "Error: make (linuxkernel) ."
        exit 1
    fi
    #Check make
    mkdir ../../${ARCH}
    cp -v ./arch/x86/boot/bzImage ../../${ARCH}/
}
#function

if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
    #x86
    # make distclean
    build x86
    #x86
fi

echo "-------------------------------------------------------------"

#x86_64
make distclean
build x86_64
#x86_64

#clean
cd ../../
rm -rf ${OBJ_PROJECT}-code-tmp
#clean

echo "Complete."
