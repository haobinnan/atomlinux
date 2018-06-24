#!/usr/bin/env bash

if [ ! -f ../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_OvmfVNumber="$(grep -i ^AtomLinux_OvmfVNumber ../VariableSetting | cut -f2 -d'=')"
AtomLinux_DownloadURL="$(grep -i ^AtomLinux_OvmfURL ../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

OBJ_PROJECT=ovmf
FILENAME=${AtomLinux_OvmfVNumber}.tar.gz

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
        echo "Error: Download ovmf ."
        exit 1
    fi
    #Check if it is downloaded successfully
    if [ ! -f ./${FILENAME} ]; then
        echo "Error: Download ovmf ."
        exit 1
    fi
fi
#Download Source Code

rm -f OVMF*.fd

rm -rf ${OBJ_PROJECT}-tmp
mkdir ${OBJ_PROJECT}-tmp
tar xzvf ./${FILENAME} -C ./${OBJ_PROJECT}-tmp
#Check Decompression
if [ ! $? -eq 0 ]; then
    echo "Error: Decompression shim ."
    exit 1
fi
#Check Decompression

cd ./${OBJ_PROJECT}-tmp/*-${AtomLinux_OvmfVNumber}

#IA32
OvmfPkg/build.sh -a IA32 -n 4
cp -v Build/OvmfIa32/DEBUG_GCC*/FV/OVMF.fd ../../OVMFIA32.fd
#IA32

#X64
OvmfPkg/build.sh -a X64 -n 4
cp -v Build/OvmfX64/DEBUG_GCC*/FV/OVMF.fd ../../OVMFX64.fd
#X64

#clean
cd ../../
rm -rf ${OBJ_PROJECT}-tmp
#clean

echo "Complete."
