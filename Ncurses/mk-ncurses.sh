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

CurrentDIR=$(pwd)
OBJ_PROJECT=ncurses
FILENAME_Prefix=${OBJ_PROJECT}-$AtomLinux_NcursesVNumber
FILENAME=${FILENAME_Prefix}.tar.gz
FILENAME_DIR=${FILENAME_Prefix}

#Clean
function clean_ncurses()
{
    rm -rf ./*-${OBJ_PROJECT}

    rm -rf ${OBJ_PROJECT}-tmp
}

if test $1 && [ $1 = "clean" ]; then
    clean_ncurses
    echo "ncurses clean ok!"
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

clean_ncurses
mkdir ${OBJ_PROJECT}-tmp
tar -xzvf ${FILENAME} -C ./${OBJ_PROJECT}-tmp/
#Check Decompression
if [ ! $? -eq 0 ]; then
    echo "Error: Decompression ncurses ."
    exit 1
fi
#Check Decompression

# --enable-widec  Support Chinese by adding this parameter
cd ./${OBJ_PROJECT}-tmp/${FILENAME_DIR}

#configure
if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    ./configure --prefix=/usr --with-shared --with-normal --with-debug --enable-overwrite --enable-widec
else
    if [ $(getconf LONG_BIT) = '64' ]; then
        ./configure --prefix=/usr --with-shared --with-normal --with-debug --enable-overwrite --enable-widec CC="gcc -m32" CXX="g++ -m32"
    else
        ./configure --prefix=/usr --with-shared --with-normal --with-debug --enable-overwrite --enable-widec
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

make install DESTDIR=$CurrentDIR/${ARCH}-$OBJ_PROJECT
#Check make install
if [ ! $? -eq 0 ]; then
    echo "Error: make install (ncurses) ."
    exit 1
fi
#Check make install

cd ../../
rm -rf ${OBJ_PROJECT}-tmp

echo "Complete."
