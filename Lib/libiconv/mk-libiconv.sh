#!/usr/bin/env bash

Make="make -j$(cat /proc/cpuinfo | grep "cpu cores" | wc -l)"

if [ ! -f ../../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_IconvVNumber="$(grep -i ^AtomLinux_IconvVNumber ../../VariableSetting | cut -f2 -d'=')"
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ../../VariableSetting | cut -f2 -d'=')"
AtomLinux_DownloadURL="$(grep -i ^AtomLinux_IconvURL ../../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

OBJ_PROJECT=libiconv
FILENAME_DIR=${OBJ_PROJECT}-$AtomLinux_IconvVNumber
FILENAME=${FILENAME_DIR}.tar.gz

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

mkdir ${OBJ_PROJECT}-${ARCH}-tmp
tar -xzvf ${FILENAME} -C ./${OBJ_PROJECT}-${ARCH}-tmp/
#Check Decompression
if [ ! $? -eq 0 ]; then
    echo "Error: Decompression libiconv ."
    exit 1
fi
#Check Decompression
cd ./${OBJ_PROJECT}-${ARCH}-tmp/${FILENAME_DIR}

#configure
if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    ./configure --prefix=$PWD/out
else
    if [ $(getconf LONG_BIT) = '64' ]; then
        ./configure --prefix=$PWD/out CC="gcc -m32"
    else
        ./configure --prefix=$PWD/out
    fi
fi
#configure

#Check configure
if [ ! $? -eq 0 ]; then
    echo "Error: configure (libiconv) ."
    exit 1
fi
#Check configure

# sed -i -e '/gets is a security/d' srclib/stdio.in.h  2017-04-27

echo | $Make
#Check make
if [ ! $? -eq 0 ]; then
    echo "Error: make (libiconv) ."
    exit 1
fi
#Check make
make install
#Check make install
if [ ! $? -eq 0 ]; then
    echo "Error: make install (libiconv) ."
    exit 1
fi
#Check make install
mkdir ../../${ARCH}-${OBJ_PROJECT}
cp -rv ./out/lib/preloadable_libiconv.so ../../${ARCH}-${OBJ_PROJECT}
cd ../../
rm -rf ${OBJ_PROJECT}-${ARCH}-tmp

echo "Complete."
