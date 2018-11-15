#!/usr/bin/env bash

Make="make -j$(cat /proc/cpuinfo | grep "cpu cores" | wc -l)"

if [ ! -f ../../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_MdadmVNumber="$(grep -i ^AtomLinux_MdadmVNumber ../../VariableSetting | cut -f2 -d'=')"
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ../../VariableSetting | cut -f2 -d'=')"
AtomLinux_DownloadURL="$(grep -i ^AtomLinux_MdadmURL ../../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

OBJ_PROJECT=mdadm
FILENAME_DIR=${OBJ_PROJECT}-$AtomLinux_MdadmVNumber
FILENAME=${FILENAME_DIR}.tar.xz

#Clean
function clean_mdadm()
{
    rm -rf ./*-${OBJ_PROJECT}

    rm -rf ${OBJ_PROJECT}-tmp
}

if test $1 && [ $1 = "clean" ]; then
    clean_mdadm
    echo "mdadm clean ok!"
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
        echo "Error: Download mdadm ."
        exit 1
    fi
    #Check if it is downloaded successfully
    if [ ! -f ./${FILENAME} ]; then
        echo "Error: Download mdadm ."
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

clean_mdadm
mkdir ${OBJ_PROJECT}-tmp
tar xvJf ./${FILENAME} -C ./${OBJ_PROJECT}-tmp
#Check Decompression
if [ ! $? -eq 0 ]; then
    echo "Error: Decompression mdadm ."
    exit 1
fi
#Check Decompression

cd ./${OBJ_PROJECT}-tmp/${FILENAME_DIR}

#make
if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    echo | $Make CXFLAGS=-O2
else
    if [ $(getconf LONG_BIT) = '64' ]; then
        echo | $Make CXFLAGS="-O2 -m32"
    else
        echo | $Make CXFLAGS=-O2
    fi
fi
#make
#Check make
if [ ! $? -eq 0 ]; then
    echo "Error: make (mdadm) ."
    exit 1
fi
#Check make

#make install
make DESTDIR=../../${ARCH}-${OBJ_PROJECT} install
#make install
#Check make install
if [ ! $? -eq 0 ]; then
    echo "Error: make install (mdadm) ."
    exit 1
fi
#Check make install

cd ../../
rm -rf ${OBJ_PROJECT}-tmp

echo "Complete."
