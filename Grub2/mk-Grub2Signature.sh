#!/usr/bin/env bash

if [ ! -f ../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
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

    if [ -f ./efi-${ARCH}/EFI/BOOT/boot${NAME}.efi ]; then
        cp -rv ./efi-${ARCH} ./efi-${ARCH}.nosign

        if [ $AtomLinux_SignatureMethod = "CodeSgin" ]; then
            cd ./efi-${ARCH}/EFI/BOOT/
            pesign --in=./boot${NAME}.efi --out=./grub${NAME}.efi -n $AtomLinux_CertificatePath -c "$AtomLinux_CertificateName" -s
            #Check pesign
            if [ ! $? -eq 0 ]; then
                echo "Error: pesign ."
                exit 1
            fi
            #Check pesign
            rm -f ./boot${NAME}.efi
            cp -v ../../../SecureBoot/shim/shim${NAME}.efi ./boot${NAME}.efi
            cd ../../../
        elif [ ${AtomLinux_SignatureMethod} = "EVCodeSgin" ]; then
            cd ./efi-${ARCH}/EFI/BOOT/
            mv ./boot${NAME}.efi ./grub${NAME}.efi
            cp -v ../../../SecureBoot/shim/shim${NAME}.efi ./boot${NAME}.efi
            echo -e "****************** \033[31mPlease sign file\033[0m:\033[33m$(pwd)/grub${NAME}.efi\033[0m ******************"
            cd ../../../
        fi
    fi
}
#function

# ***************** Signature i386 *****************
Grub2Signature i386 ia32
# ***************** Signature i386 *****************

# ***************** Signature x86_64 *****************
Grub2Signature x86_64 x64
# ***************** Signature x86_64 *****************

echo "Complete."
