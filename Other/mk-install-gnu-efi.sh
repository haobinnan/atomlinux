#!/usr/bin/env bash

if test $1 && [ $1 = "clean" ]; then
    sudo rm -rf /usr/include/efi
    sudo rm -rf /usr/lib/gnuefi
    sudo rm -rf /usr/lib64/gnuefi

    echo "clean ok!"
    exit
fi

Make="make -j$(cat /proc/cpuinfo | grep "cpu cores" | wc -l)"

if [ ! -f ../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_GnuEFIVNumber="$(grep -i ^AtomLinux_GnuEFIVNumber ../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

OBJ_PROJECT=gnu-efi
FILENAME=${OBJ_PROJECT}-${AtomLinux_GnuEFIVNumber}.tar.bz2

#Download Source Code
if [ ! -f ./${FILENAME} ]; then
    #Check if necessary tools are installed
    if [ -z $(which wget) ]; then
        echo "wget is not installed."
        exit 1
    fi
    #Check if necessary tools are installed
    wget https://jaist.dl.sourceforge.net/project/gnu-efi/${FILENAME}
    if [ ! $? -eq 0 ]; then
        echo "Error: Download gnu-efi ."
        exit 1
    fi
    #Check if it is downloaded successfully
    if [ ! -f ./${FILENAME} ]; then
        echo "Error: Download gnu-efi ."
        exit 1
    fi
fi
#Download Source Code

mkdir ${OBJ_PROJECT}-tmp
tar xjvf ./${FILENAME} -C ./${OBJ_PROJECT}-tmp
#Check Decompression
if [ ! $? -eq 0 ]; then
    echo "Error: Decompression gnu-efi ."
    exit 1
fi
#Check Decompression

CurrentDIR=$(pwd)/${OBJ_PROJECT}-tmp/out

cd ./${OBJ_PROJECT}-tmp/${OBJ_PROJECT}-${AtomLinux_GnuEFIVNumber}

#function
function build()
{
    ARCH=$1
    INSTALLDIR=$2

    rm -rf ${INSTALLDIR}/*
    echo | $Make ARCH=$ARCH
    #Check make
    if [ ! $? -eq 0 ]; then
        echo "Error: make (gnu-efi) ."
        exit 1
    fi
    #Check make
    make ARCH=$ARCH install INSTALLROOT=${INSTALLDIR}
    make ARCH=$ARCH clean

    #install
    if [ ${ARCH} = "ia32" ]; then
        sudo cp -rv ${INSTALLDIR}/usr/local/include/efi /usr/include
        sudo rm -rf /usr/lib/gnuefi
        sudo mkdir -p /usr/lib/gnuefi
        sudo cp -rv ${INSTALLDIR}/usr/local/lib/* /usr/lib/gnuefi
    elif [ ${ARCH} = "amd64" ]; then
        sudo cp -rv ${INSTALLDIR}/usr/local/include/efi /usr/include
        sudo rm -rf /usr/lib64/gnuefi
        sudo mkdir -p /usr/lib64/gnuefi
        sudo cp -rv ${INSTALLDIR}/usr/local/lib/* /usr/lib64/gnuefi
    fi
    #install
}
#function

#delete install
sudo rm -rf /usr/include/efi
#delete install

#x86
build ia32 ${CurrentDIR}
#x86

echo "-------------------------------------------------------------"

#x86_64
build amd64 ${CurrentDIR}
#x86_64

#clean
cd ../../
rm -rf ${OBJ_PROJECT}-tmp
rm -rf ./${FILENAME}
#clean

echo "Complete."
