#!/usr/bin/env bash

if [ ! -f ../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_SignatureMethod="$(grep -i ^AtomLinux_SignatureMethod ../VariableSetting | cut -f2 -d'=')"
AtomLinux_key="$(grep -i ^AtomLinux_key ../VariableSetting | cut -f2 -d'=')"
AtomLinux_crt="$(grep -i ^AtomLinux_crt ../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

#Check files
if [ $AtomLinux_SignatureMethod = "CodeSgin" ]; then
    if [ ! -f ../certificate/$AtomLinux_key ]; then
        echo "Error: key file does not exist ."
        exit 1
    fi

    if [ ! -f ../certificate/$AtomLinux_crt ]; then
        echo "Error: crt file does not exist ."
        exit 1
    fi
fi

if [ ! -f ./SecureBoot/shim/shimia32.efi ]; then
    echo "Error: shimia32.efi file does not exist ."
    exit 1
fi

if [ ! -f ./SecureBoot/shim/shimx64.efi ]; then
    echo "Error: shimx64.efi file does not exist ."
    exit 1
fi
#Check files

#function
function Grub2Signature()
{
    ARCH=$1
    NAME=$2

    cp -rv ./efi-${ARCH} ./efi-${ARCH}.nosign

    if [ $AtomLinux_SignatureMethod = "CodeSgin" ]; then
        cd ./efi-${ARCH}/EFI/BOOT/
        sbsign --key ../../../../certificate/${AtomLinux_key} --cert ../../../../certificate/${AtomLinux_crt} --output ./grub${NAME}.efi ./boot${NAME}.efi
        #Check sbsign
        if [ ! $? -eq 0 ]; then
            echo "Error: sbsign ."
            exit 1
        fi
        #Check sbsign
        rm -f ./boot${NAME}.efi
        cp -v ../../../SecureBoot/shim/shim${NAME}.efi ./boot${NAME}.efi
        #sbverify --cert ../../../../certificate/${AtomLinux_crt} ./grub${NAME}.efi
        cd ../../../
    elif [ ${AtomLinux_SignatureMethod} = "EVCodeSgin" ]; then
        cd ./efi-${ARCH}/EFI/BOOT/
        mv ./boot${NAME}.efi ./grub${NAME}.efi
        cp -v ../../../SecureBoot/shim/shim${NAME}.efi ./boot${NAME}.efi
        echo -e "****************** \033[31mPlease sign file\033[0m:\033[33m$(pwd)/grub${NAME}.efi\033[0m ******************"
        cd ../../../
    fi
}
#function

# ***************** Signature i386 *****************
Grub2Signature i386 ia32
#Check Grub2Signature i386
if [ ! $? -eq 0 ]; then
    echo "Error: Grub2Signature (i386) ."
    exit 1
fi
#Check Grub2Signature i386
# ***************** Signature i386 *****************

# ***************** Signature x86_64 *****************
Grub2Signature x86_64 x64
#Check Grub2Signature x86_64
if [ ! $? -eq 0 ]; then
    echo "Error: Grub2Signature (x86_64) ."
    exit 1
fi
#Check Grub2Signature x86_64
# ***************** Signature x86_64 *****************

echo "Complete."
