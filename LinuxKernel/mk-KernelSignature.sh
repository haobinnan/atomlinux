#!/usr/bin/env bash

if [ ! -f ../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ../VariableSetting | cut -f2 -d'=')"
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

if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
    if [ ! -f ./x86/bzImage ]; then
        echo "Error: bzImage(x86) file does not exist ."
        exit 1
    fi
fi

if [ ! -f ./x86_64/bzImage ]; then
    echo "Error: bzImage(x86_64) file does not exist ."
    exit 1
fi
#Check files

#function
function KernelSignature()
{
    ARCH=$1

    cp -rv ./${ARCH} ./${ARCH}.nosign

    if [ $AtomLinux_SignatureMethod = "CodeSgin" ]; then
        cd ./${ARCH}/
        mv ./bzImage ./bzImage.nosign
        sbsign --key ../../certificate/${AtomLinux_key} --cert ../../certificate/${AtomLinux_crt} --output ./bzImage ./bzImage.nosign
        #Check sbsign
        if [ ! $? -eq 0 ]; then
            echo "Error: sbsign ."
            exit 1
        fi
        #Check sbsign
        rm ./bzImage.nosign
        cd ../
    elif [ ${AtomLinux_SignatureMethod} = "EVCodeSgin" ]; then
        echo -e "****************** \033[31mPlease sign file\033[0m:\033[33m$(pwd)/${ARCH}/bzImage\033[0m ******************"
    fi
}
#function

# ***************** Signature x86 *****************
if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
    KernelSignature x86
    #Check KernelSignature x86
    if [ ! $? -eq 0 ]; then
        echo "Error: KernelSignature (x86) ."
        exit 1
    fi
    #Check KernelSignature x86
fi
# ***************** Signature x86 *****************

# ***************** Signature x86_64 *****************
KernelSignature x86_64
#Check KernelSignature x86_64
if [ ! $? -eq 0 ]; then
    echo "Error: KernelSignature (x86_64) ."
    exit 1
fi
#Check KernelSignature x86_64
# ***************** Signature x86_64 *****************

echo "Complete."
