#!/usr/bin/env bash

Make="make -j$(cat /proc/cpuinfo | grep "cpu cores" | wc -l)"

if [ ! -f ../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_ShimVNumber="$(grep -i ^AtomLinux_ShimVNumber ../VariableSetting | cut -f2 -d'=')"
AtomLinux_cer="$(grep -i ^AtomLinux_cer ../VariableSetting | cut -f2 -d'=')"
AtomLinux_DownloadURL="$(grep -i ^AtomLinux_ShimURL ../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

#Use Existing Certificate  (yes | no)
UseExistingCertificate=yes
#Use Existing Certificate  (yes | no)

if [ $UseExistingCertificate = "yes" ]; then
    if [ ! -f ../certificate/$AtomLinux_cer ]; then
        echo "Error: VendorCertfile does not exist ."
        exit 1
    fi
fi

OBJ_PROJECT=shim
FILENAME=${AtomLinux_ShimVNumber}.tar.gz

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
        echo "Error: Download shim ."
        exit 1
    fi
    #Check if it is downloaded successfully
    if [ ! -f ./${FILENAME} ]; then
        echo "Error: Download shim ."
        exit 1
    fi
fi
#Download Source Code

rm -rf ./${OBJ_PROJECT}_result
mkdir ${OBJ_PROJECT}_result

#function
function build()
{
    ARCH=$1
    NAME=$2

    mkdir ${OBJ_PROJECT}-tmp
    tar xzvf ./${FILENAME} -C ./${OBJ_PROJECT}-tmp
    #Check Decompression
    if [ ! $? -eq 0 ]; then
        echo "Error: Decompression shim ."
        exit 1
    fi
    #Check Decompression

    cd ./${OBJ_PROJECT}-tmp/${OBJ_PROJECT}-${AtomLinux_ShimVNumber}

    if [ $UseExistingCertificate = "yes" ]; then
        echo | $Make ARCH=$ARCH VENDOR_CERT_FILE=../../../certificate/$AtomLinux_cer 2>&1 | tee ../../shim_build_${NAME}.log
    else
        echo | $Make ARCH=$ARCH ENABLE_SHIM_CERT=1
    fi
    #Check make
    if [ ! $? -eq 0 ]; then
        echo "Error: make (shim) ."
        exit 1
    fi
    #Check make

    cp -v ./*${NAME}.efi ../../${OBJ_PROJECT}_result/
    cp -v ./*${NAME}.efi.* ../../${OBJ_PROJECT}_result/

    #Copy Certificate
    if [ $UseExistingCertificate = "no" ]; then
        if [ ! -d ../../${OBJ_PROJECT}_result/certificate/ ]; then
            mkdir ../../${OBJ_PROJECT}_result/certificate/
            cp -v ./*.pem *.p12 *.key *.csr *.crt *.cer ../../${OBJ_PROJECT}_result/certificate/
        fi
    fi
    #Copy Certificate

    #clean
    cd ../../
    rm -rf ${OBJ_PROJECT}-tmp
    #clean
}
#function

#x86
build ia32 ia32
#x86

echo "-------------------------------------------------------------"

#x86_64
build x86_64 x64
#x86_64

echo "Complete."
