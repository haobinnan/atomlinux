#!/usr/bin/env bash

Make="make -j$(cat /proc/cpuinfo | grep "cpu cores" | wc -l)"

if [ ! -f ../../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_Ntfs3gVNumber="$(grep -i ^AtomLinux_Ntfs3gVNumber ../../VariableSetting | cut -f2 -d'=')"
AtomLinux_DownloadURL="$(grep -i ^AtomLinux_Ntfs3gURL ../../VariableSetting | cut -f2 -d'=')"
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ../../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

CurrentDIR=$(pwd)
OBJ_PROJECT=ntfs-3g
FILENAME_DIR=${OBJ_PROJECT}_ntfsprogs-${AtomLinux_Ntfs3gVNumber}
FILENAME=${FILENAME_DIR}.tgz

#Clean
function clean_Ntfs3g()
{
    rm -rf ./*-${OBJ_PROJECT}

    rm -rf ${OBJ_PROJECT}-tmp
}

if test $1 && [ $1 = "clean" ]; then
    clean_Ntfs3g
    echo "ntfs-3g clean ok!"
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
        echo "Error: Download ntfs-3g ."
        exit 1
    fi
    #Check if it is downloaded successfully
    if [ ! -f ./${FILENAME} ]; then
        echo "Error: Download ntfs-3g ."
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

clean_Ntfs3g
mkdir ${OBJ_PROJECT}-tmp
tar xzvf ./${FILENAME} -C ./${OBJ_PROJECT}-tmp
#Check Decompression
if [ ! $? -eq 0 ]; then
    echo "Error: Decompression ntfs-3g ."
    exit 1
fi
#Check Decompression

cd ./${OBJ_PROJECT}-tmp/${FILENAME_DIR}

#configure
if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    ./configure --prefix=$PWD/../../${ARCH}-${OBJ_PROJECT}
else
    if [ $(getconf LONG_BIT) = '64' ]; then
        ./configure --prefix=$PWD/../../${ARCH}-${OBJ_PROJECT} CC="gcc -m32" CXX="g++ -m32"
    else
        ./configure --prefix=$PWD/../../${ARCH}-${OBJ_PROJECT}
    fi
fi
#configure
#Check configure
if [ ! $? -eq 0 ]; then
    echo "Error: configure (ntfs-3g) ."
    exit 1
fi
#Check configure

echo | $Make
#Check make
if [ ! $? -eq 0 ]; then
    echo "Error: make (ntfs-3g) ."
    exit 1
fi
#Check make

sudo make install
#Check make install
if [ ! $? -eq 0 ]; then
    echo "Error: make install (ntfs-3g) ."
    exit 1
fi
#Check make install
sudo cp -v /bin/ntfs-3g  ../../${ARCH}-${OBJ_PROJECT}/bin/
sudo cp -dv /lib/libntfs-3g*  ../../${ARCH}-${OBJ_PROJECT}/lib/
sudo chown -R "$USER":`groups | awk -F " " '{print $1}'` ../../${ARCH}-${OBJ_PROJECT}
rm -rf ../../${ARCH}-${OBJ_PROJECT}/include
rm -rf ../../${ARCH}-${OBJ_PROJECT}/share
rm -rf ../../${ARCH}-${OBJ_PROJECT}/lib/ntfs-3g
rm -rf ../../${ARCH}-${OBJ_PROJECT}/lib/pkgconfig
rm -f ../../${ARCH}-${OBJ_PROJECT}/lib/*.a
rm -f ../../${ARCH}-${OBJ_PROJECT}/lib/*.la

cd ../../
rm -rf ${OBJ_PROJECT}-tmp

echo "Complete."
