#!/usr/bin/env bash

if [ ! -f ../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_OvmfVNumber="$(grep -i ^AtomLinux_OvmfVNumber ../VariableSetting | cut -f2 -d'=')"
AtomLinux_DownloadURL="$(grep -i ^AtomLinux_OvmfURL ../VariableSetting | cut -f2 -d'=')"

AtomLinux_SecureBootSignature="$(grep -i ^AtomLinux_SecureBootSignature ../VariableSetting | cut -f2 -d'=')"
AtomLinux_OvmfOpenSSLVNumber="$(grep -i ^AtomLinux_OvmfOpenSSLVNumber ../VariableSetting | cut -f2 -d'=')"
AtomLinux_OvmfOpenSSLURL="$(grep -i ^AtomLinux_OvmfOpenSSLURL ../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

OBJ_PROJECT=ovmf
FILENAME=${AtomLinux_OvmfVNumber}.tar.gz

#Clean
function clean_ovmf()
{
    rm -f ./OVMF*.fd

    rm -rf ${OBJ_PROJECT}-tmp
}

if test $1 && [ $1 = "clean" ]; then
    clean_ovmf
    echo "ovmf clean ok!"
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

clean_ovmf
mkdir ${OBJ_PROJECT}-tmp
tar xzvf ./${FILENAME} -C ./${OBJ_PROJECT}-tmp
#Check Decompression
if [ ! $? -eq 0 ]; then
    echo "Error: Decompression ovmf ."
    exit 1
fi
#Check Decompression

#OpenSSL
if [ ${AtomLinux_SecureBootSignature} = "Yes" ]; then
    FILENAME=${AtomLinux_OvmfOpenSSLVNumber}.tar.gz

    #Download Source Code
    if [ ! -f ./${FILENAME} ]; then
        #Check if necessary tools are installed
        if [ -z $(which wget) ]; then
            echo "wget is not installed."
            exit 1
        fi
        #Check if necessary tools are installed
        wget ${AtomLinux_OvmfOpenSSLURL}${FILENAME}
        if [ ! $? -eq 0 ]; then
            echo "Error: Download ovmf_openssl ."
            exit 1
        fi
        #Check if it is downloaded successfully
        if [ ! -f ./${FILENAME} ]; then
            echo "Error: Download ovmf_openssl ."
            exit 1
        fi
    fi
    #Download Source Code

    tar xzvf ./${FILENAME} -C ./${OBJ_PROJECT}-tmp
    #Check Decompression
    if [ ! $? -eq 0 ]; then
        echo "Error: Decompression ovmf_openssl ."
        exit 1
    fi
    #Check Decompression

    rm -rf ./${OBJ_PROJECT}-tmp/*-${AtomLinux_OvmfVNumber}/CryptoPkg/Library/OpensslLib/openssl
    mv ./${OBJ_PROJECT}-tmp/openssl-*/ ./${OBJ_PROJECT}-tmp/edk2-${AtomLinux_OvmfVNumber}/CryptoPkg/Library/OpensslLib/openssl/
fi
#OpenSSL

cd ./${OBJ_PROJECT}-tmp/*-${AtomLinux_OvmfVNumber}

#IA32
if [ ${AtomLinux_SecureBootSignature} = "Yes" ]; then
    OvmfPkg/build.sh -a IA32 -b RELEASE -DSECURE_BOOT_ENABLE=TRUE
else
    OvmfPkg/build.sh -a IA32 -b RELEASE
fi
cp -v Build/OvmfIa32/RELEASE_GCC*/FV/OVMF.fd ../../OVMF_IA32.fd
cp -v Build/OvmfIa32/RELEASE_GCC*/FV/OVMF.fd ../../OVMF_IA32_BAK.fd

cp -v Build/OvmfIa32/RELEASE_GCC*/FV/OVMF_CODE.fd ../../OVMF_CODE_IA32.fd
cp -v Build/OvmfIa32/RELEASE_GCC*/FV/OVMF_VARS.fd ../../OVMF_VARS_IA32.fd
#IA32

#X64
if [ ${AtomLinux_SecureBootSignature} = "Yes" ]; then
    OvmfPkg/build.sh -a X64 -b RELEASE -DSECURE_BOOT_ENABLE=TRUE
else
    OvmfPkg/build.sh -a X64 -b RELEASE
fi
cp -v Build/OvmfX64/RELEASE_GCC*/FV/OVMF.fd ../../OVMF_X64.fd
cp -v Build/OvmfX64/RELEASE_GCC*/FV/OVMF.fd ../../OVMF_X64_BAK.fd

cp -v Build/OvmfX64/RELEASE_GCC*/FV/OVMF_CODE.fd ../../OVMF_CODE_X64.fd
cp -v Build/OvmfX64/RELEASE_GCC*/FV/OVMF_VARS.fd ../../OVMF_VARS_X64.fd
#X64

#clean
cd ../../
rm -rf ${OBJ_PROJECT}-tmp
#clean

echo "Complete."
