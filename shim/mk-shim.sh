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
AtomLinux_DownloadURL="$(grep -i ^AtomLinux_ShimURL ../VariableSetting | cut -f2 -d'=')"

AtomLinux_SBAT_DISTRO_ID="$(grep -i ^AtomLinux_SBAT_DISTRO_ID ../VariableSetting | cut -f2 -d'=')"
AtomLinux_SBAT_DISTRO_NAME="$(grep -i ^AtomLinux_SBAT_DISTRO_NAME ../VariableSetting | cut -f2 -d'=')"
AtomLinux_SBAT_URL="$(grep -i ^AtomLinux_SBAT_URL ../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

#Use Existing Certificate  (yes | no)
UseExistingCertificate=yes
#Use Existing Certificate  (yes | no)

CertFile=certs/CertFile.cer

OBJ_PROJECT=shim

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

if [ $UseExistingCertificate = "yes" ]; then
    if [ ! -f ./$CertFile ]; then
        echo "Error: VendorCertfile does not exist ."
        exit 1
    fi
fi

clean_shim
mkdir ${OBJ_PROJECT}_result
mkdir ${OBJ_PROJECT}-tmp

#git clone Source Code
cd ./${OBJ_PROJECT}-tmp/
git clone --branch ${AtomLinux_ShimVNumber} ${AtomLinux_DownloadURL}
#Check git clone
if [ ! $? -eq 0 ]; then
    echo "Error: git clone shim ."
    exit 1
fi
#Check git clone
cd ${OBJ_PROJECT}
git submodule update --init
#Check git clone
if [ ! $? -eq 0 ]; then
    echo "Error: git clone shim - submodule ."
    exit 1
fi
#Check git clone
cd ../../
#git clone Source Code

#function
function build()
{
    ARCH=$1
    NAME=$2
    DEL=$3

    cd ./${OBJ_PROJECT}-tmp/${OBJ_PROJECT}

    if [ ${DEL} = "TRUE" ]; then
        make clean
    fi

    #sbat.csv
    echo 'shim.'${AtomLinux_SBAT_DISTRO_ID}',1,'${AtomLinux_SBAT_DISTRO_NAME}','${OBJ_PROJECT}','${AtomLinux_ShimVNumber}','${AtomLinux_SBAT_URL} > ./data/sbat.${AtomLinux_SBAT_DISTRO_ID}.csv
    #sbat.csv

    if [ $UseExistingCertificate = "yes" ]; then
        echo | $Make ARCH=$ARCH ENABLE_HTTBOOT=1 VENDOR_CERT_FILE=../../$CertFile 2>&1 | tee ../../shim_build_${NAME}.log
    else
        echo | $Make ARCH=$ARCH ENABLE_HTTBOOT=1 ENABLE_SHIM_CERT=1
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
    #clean
}
#function

#x86
build ia32 ia32 FALSE
#x86

echo "-------------------------------------------------------------"

#x86_64
build x86_64 x64 TRUE
#x86_64

rm -rf ${OBJ_PROJECT}-tmp

echo "Complete."
