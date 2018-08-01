#!/usr/bin/env bash

Make="make -j$(cat /proc/cpuinfo | grep "cpu cores" | wc -l)"

if [ ! -f ../../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_GlibVNumber="$(grep -i ^AtomLinux_GlibVNumber ../../VariableSetting | cut -f2 -d'=')"
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ../../VariableSetting | cut -f2 -d'=')"
AtomLinux_DownloadURL="$(grep -i ^AtomLinux_GlibURL ../../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

OBJ_PROJECT=glib
FILENAME_DIR=${OBJ_PROJECT}-$AtomLinux_GlibVNumber
FILENAME=${FILENAME_DIR}.tar.xz

#Clean
function clean_glib()
{
    rm -rf ./*-glib

    rm -rf ${OBJ_PROJECT}-tmp
}

if test $1 && [ $1 = "clean" ]; then
    clean_glib
    echo "glib clean ok!"
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
        echo "Error: Download glib ."
        exit 1
    fi
    #Check if it is downloaded successfully
    if [ ! -f ./${FILENAME} ]; then
        echo "Error: Download glib ."
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

clean_glib
mkdir ${OBJ_PROJECT}-tmp
tar xvJf ./${FILENAME} -C ./${OBJ_PROJECT}-tmp
#Check Decompression
if [ ! $? -eq 0 ]; then
    echo "Error: Decompression glib ."
    exit 1
fi
#Check Decompression
mkdir ./${ARCH}-${OBJ_PROJECT}
cd ./${OBJ_PROJECT}-tmp/${FILENAME_DIR}

#configure
if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    ./configure --prefix=$PWD/../../${ARCH}-${OBJ_PROJECT} --enable-static --disable-shared CFLAGS="-static"
else
    if [ $(getconf LONG_BIT) = '64' ]; then
        ./configure --prefix=$PWD/../../${ARCH}-${OBJ_PROJECT} --enable-static --disable-shared CFLAGS="-static" CC="gcc -m32" CXX="g++ -m32"
    else
        ./configure --prefix=$PWD/../../${ARCH}-${OBJ_PROJECT} --enable-static --disable-shared CFLAGS="-static"
    fi
fi
#configure

#Check configure
if [ ! $? -eq 0 ]; then
    echo "Error: configure (glib) ."
    exit 1
fi
#Check configure
echo | $Make
#Check make
if [ ! $? -eq 0 ]; then
    echo "Error: make (glib) ."
    exit 1
fi
#Check make
make install
#Check make install
if [ ! $? -eq 0 ]; then
    echo "Error: make install (glib) ."
    exit 1
fi
#Check make install
cd ../../
rm -rf ${OBJ_PROJECT}-tmp

echo "Complete."
