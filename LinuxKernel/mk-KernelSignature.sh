#!/usr/bin/env bash

if [ ! -f ../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ../VariableSetting | cut -f2 -d'=')"
AtomLinux_SignatureMethod="$(grep -i ^AtomLinux_SignatureMethod ../VariableSetting | cut -f2 -d'=')"
AtomLinux_CertificatePath="$(grep -i ^AtomLinux_CertificatePath ../VariableSetting | cut -f2 -d'=')"
AtomLinux_CertificateName="$(grep -i ^AtomLinux_CertificateName ../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

#Check files
if [ $AtomLinux_SignatureMethod = "CodeSgin" ]; then
    certutil -L -d $AtomLinux_CertificatePath -n "$AtomLinux_CertificateName" > /dev/null
    if [ ! $? -eq 0 ]; then
        echo "Error: Secure boot signature certificate does not exist."
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

    rm -rf ./${ARCH}.nosign
    cp -rv ./${ARCH} ./${ARCH}.nosign

    if [ $AtomLinux_SignatureMethod = "CodeSgin" ]; then
        cd ./${ARCH}/
        mv ./bzImage ./bzImage.nosign
        pesign --in=./bzImage.nosign --out=./bzImage -n $AtomLinux_CertificatePath -c "$AtomLinux_CertificateName" -s
        #Check pesign
        if [ ! $? -eq 0 ]; then
            echo "Error: pesign ."
            exit 1
        fi
        #Check pesign
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
fi
# ***************** Signature x86 *****************

# ***************** Signature x86_64 *****************
KernelSignature x86_64
# ***************** Signature x86_64 *****************

echo "Complete."
