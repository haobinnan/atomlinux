#!/usr/bin/env bash

Make="make -j$(cat /proc/cpuinfo | grep "cpu cores" | wc -l)"

if [ ! -f ../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_NcursesVNumber="$(grep -i ^AtomLinux_NcursesVNumber ../VariableSetting | cut -f2 -d'=')"
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ../VariableSetting | cut -f2 -d'=')"
AtomLinux_DownloadURL="$(grep -i ^AtomLinux_NcursesURL ../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

OBJ_PROJECT=ncurses
FILENAME_Prefix=${OBJ_PROJECT}-$AtomLinux_NcursesVNumber
FILENAME=${FILENAME_Prefix}.tar.gz
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
        echo "Error: Download ncurses ."
        exit 1
    fi
    #Check if it is downloaded successfully
    if [ ! -f ./${FILENAME} ]; then
        echo "Error: Download ncurses ."
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

CurrentDIR=$(pwd)
mkdir ${OBJ_PROJECT}-${ARCH}-tmp
tar -xzvf ${FILENAME} -C ./${OBJ_PROJECT}-${ARCH}-tmp/
#Check Decompression
if [ ! $? -eq 0 ]; then
    echo "Error: Decompression ncurses ."
    exit 1
fi
#Check Decompression

# --enable-widec  Support Chinese by adding this parameter
cd ./${OBJ_PROJECT}-${ARCH}-tmp/${FILENAME_DIR}

#configure
if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    ./configure --prefix=$CurrentDIR/${ARCH}-$OBJ_PROJECT --with-shared --with-normal --with-debug --enable-overwrite --enable-widec
else
    if [ $(getconf LONG_BIT) = '64' ]; then
        ./configure --prefix=$CurrentDIR/${ARCH}-$OBJ_PROJECT --with-shared --with-normal --with-debug --enable-overwrite --enable-widec CC="gcc -m32" CXX="g++ -m32"
    else
        ./configure --prefix=$CurrentDIR/${ARCH}-$OBJ_PROJECT --with-shared --with-normal --with-debug --enable-overwrite --enable-widec
    fi
fi
#configure

#Check configure
if [ ! $? -eq 0 ]; then
    echo "Error: configure (ncurses) ."
    exit 1
fi
#Check configure
echo | $Make
#Check make
if [ ! $? -eq 0 ]; then
    echo "Error: make (ncurses) ."
    exit 1
fi
#Check make
make install
#Check make install
if [ ! $? -eq 0 ]; then
    echo "Error: make install (ncurses) ."
    exit 1
fi
#Check make install

cd ../../
rm -rf ${OBJ_PROJECT}-${ARCH}-tmp

echo "Complete."
