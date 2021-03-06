#!/usr/bin/env bash

if [ ! -f ../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_OvmfVNumber="$(grep -i ^AtomLinux_OvmfVNumber ../VariableSetting | cut -f2 -d'=')"

AtomLinux_SecureBootSignature="$(grep -i ^AtomLinux_SecureBootSignature ../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

OBJ_PROJECT=ovmf

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

clean_ovmf

mkdir ${OBJ_PROJECT}-tmp
cd ./${OBJ_PROJECT}-tmp

git clone --branch ${AtomLinux_OvmfVNumber} https://github.com/tianocore/edk2.git
#Check git clone
if [ ! $? -eq 0 ]; then
    echo "Error: git clone ovmf ."
    exit 1
fi
#Check git clone
cd edk2
git submodule update --init
#Check git clone
if [ ! $? -eq 0 ]; then
    echo "Error: git clone ovmf - submodule ."
    exit 1
fi
#Check git clone
cd ../../

cd ./${OBJ_PROJECT}-tmp/edk2

#IA32
if [ ${AtomLinux_SecureBootSignature} = "Yes" ]; then
    OvmfPkg/build.sh -a IA32 -b RELEASE -DSECURE_BOOT_ENABLE
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
    OvmfPkg/build.sh -a X64 -b RELEASE -DSECURE_BOOT_ENABLE
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
