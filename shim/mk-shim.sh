#!/usr/bin/env bash

if [ $(getconf LONG_BIT) != '64' ]; then
    echo "SHIM Only supports compiling on 64-Bit systems ."
    exit 1
fi

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

#Clean
function clean_shim()
{
    rm -f ./*.log
    rm -rf ./shim_result

    rm -rf ${OBJ_PROJECT}-tmp
}

if test $1 && [ $1 = "clean" ]; then
    clean_shim
    echo "shim clean ok!"
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

clean_shim
mkdir ${OBJ_PROJECT}_result

#function
function build()
{
    ARCH=$1
    NAME=$2

    rm -rf ${OBJ_PROJECT}-tmp
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
    if [ ! -f ./shim${NAME}.efi ]; then
        echo "Error: make (shim) ."
        exit 1
    fi
    #Check make

    cp -v ./*${NAME}.efi ../../${OBJ_PROJECT}_result/
    cp -v ./*${NAME}.efi.* ../../${OBJ_PROJECT}_result/

    #cab & sha256sum
    DATE=`date --date='0 days ago' +%Y%m%d`
    lcab shim${NAME}.efi ../../${OBJ_PROJECT}_result/shim${NAME}_v${AtomLinux_ShimVNumber}_${DATE}.cab
    SHA256SUM=$(sha256sum -b ./shim${NAME}.efi | awk '{print $1}')
    echo ${SHA256SUM} > ../../${OBJ_PROJECT}_result/shim${NAME}.efi.sha256sum
    #cab & sha256sum

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
