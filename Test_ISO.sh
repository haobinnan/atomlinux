#!/usr/bin/env bash

if [ ! -f ./VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_ISOName="$(grep -i ^AtomLinux_ISOName ./VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

QEMURunParameter="-smp 2 -m 256M -cdrom ${AtomLinux_ISOName} -boot d"
if [ -c /dev/kvm ]; then
    QEMURunParameter=${QEMURunParameter}" -enable-kvm"
else
    echo -e "\033[31mKVM is not supported.\033[0m"
fi

#Legacy BIOS
echo -e "\033[31mPlatform: 32-Bit(Legacy BIOS)\033[0m"
sudo qemu-system-i386 ${QEMURunParameter}
if [ $(getconf LONG_BIT) = '64' ]; then
    echo -e "\033[31mPlatform: 64-Bit(Legacy BIOS)\033[0m"
    sudo qemu-system-x86_64 ${QEMURunParameter}
fi
#Legacy BIOS

#UEFI BIOS
# 32Bit
OVMFPath="./ovmf/OVMFIA32.fd"
if [ -f ${OVMFPath} ]; then
    if [ $(getconf LONG_BIT) = '64' ]; then
        echo -e "\033[31mPlatform: 32-Bit(32Bit UEFI BIOS)\033[0m"
        sudo qemu-system-i386 -bios "${OVMFPath}" ${QEMURunParameter}
        echo -e "\033[31mPlatform: 64-Bit(32Bit UEFI BIOS)\033[0m"
        sudo qemu-system-x86_64 -bios "${OVMFPath}" ${QEMURunParameter}
    else
        echo -e "\033[31mPlatform: 32-Bit(32Bit UEFI BIOS)\033[0m"
        sudo qemu-system-i386 -bios "${OVMFPath}" ${QEMURunParameter}
    fi
else
    echo -e "\"${OVMFPath}\" \033[31mfile does not exist .\033[0m"
fi
# 32Bit

# 64Bit
if [ $(getconf LONG_BIT) = '64' ]; then
    OVMFPath="./ovmf/OVMFX64.fd"
    if [ -f ${OVMFPath} ]; then
        echo -e "\033[31mPlatform: 64-Bit(64Bit UEFI BIOS)\033[0m"
        sudo qemu-system-x86_64 -bios "${OVMFPath}" ${QEMURunParameter}
    else
        echo -e "\"${OVMFPath}\" \033[31mfile does not exist .\033[0m"
    fi
fi
# 64Bit
#UEFI BIOS
