#!/usr/bin/env bash

Make="make -j$(cat /proc/cpuinfo | grep "cpu cores" | wc -l)"

if [ ! -f ../../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_IconvVNumber="$(grep -i ^AtomLinux_IconvVNumber ../../VariableSetting | cut -f2 -d'=')"
AtomLinux_DownloadURL="$(grep -i ^AtomLinux_IconvURL ../../VariableSetting | cut -f2 -d'=')"
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ../../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

CurrentDIR=$(pwd)
OBJ_PROJECT=libiconv
FILENAME_DIR=${OBJ_PROJECT}-$AtomLinux_IconvVNumber
FILENAME=${FILENAME_DIR}.tar.gz

#Clean
function clean_libiconv()
{
    rm -rf ./*-${OBJ_PROJECT}

    rm -rf ${OBJ_PROJECT}-tmp
}

if test $1 && [ $1 = "clean" ]; then
    clean_libiconv
    echo "libiconv clean ok!"
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
        echo "Error: Download libiconv ."
        exit 1
    fi
    #Check if it is downloaded successfully
    if [ ! -f ./${FILENAME} ]; then
        echo "Error: Download libiconv ."
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

clean_libiconv
mkdir ${OBJ_PROJECT}-tmp
tar -xzvf ${FILENAME} -C ./${OBJ_PROJECT}-tmp/
#Check Decompression
if [ ! $? -eq 0 ]; then
    echo "Error: Decompression libiconv ."
    exit 1
fi
#Check Decompression
cd ./${OBJ_PROJECT}-tmp/${FILENAME_DIR}

#configure
if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    ./configure --prefix=/usr
else
    if [ $(getconf LONG_BIT) = '64' ]; then
        ./configure --prefix=/usr CC="gcc -m32"
    else
        ./configure --prefix=/usr
    fi
fi
#configure
#Check configure
if [ ! $? -eq 0 ]; then
    echo "Error: configure (libiconv) ."
    exit 1
fi
#Check configure

echo | $Make
#Check make
if [ ! $? -eq 0 ]; then
    echo "Error: make (libiconv) ."
    exit 1
fi
#Check make
make install DESTDIR=${CurrentDIR}/${ARCH}-${OBJ_PROJECT}
#Check make install
if [ ! $? -eq 0 ]; then
    echo "Error: make install (libiconv) ."
    exit 1
fi
#Check make install

cd ../../
rm -rf ${OBJ_PROJECT}-tmp

echo "Complete."
