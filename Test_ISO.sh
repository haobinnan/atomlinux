#!/usr/bin/env bash

if [ ! -f ./VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_ISOName="$(grep -i ^AtomLinux_ISOName ./VariableSetting | cut -f2 -d'=')"
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ./VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

#BIOS
if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    qemu-system-x86_64 -m 256M -cdrom ${AtomLinux_ISOName} -boot d -vga std
else
    qemu-system-i386 -m 256M -cdrom ${AtomLinux_ISOName} -boot d -vga std
fi
#BIOS

#UEFI
OVMFPath="./ovmf/OVMFX64.fd"
if [ -f ${OVMFPath} ]; then
    qemu-system-x86_64 -bios "${OVMFPath}" -m 256M -cdrom ${AtomLinux_ISOName} -boot d -vga std
else
    echo -e "\"${OVMFPath}\" \033[31mfile does not exist .\033[0m"
fi

OVMFPath="./ovmf/OVMFIA32.fd"
if [ -f ${OVMFPath} ]; then
    qemu-system-i386 -bios "${OVMFPath}" -m 256M -cdrom ${AtomLinux_ISOName} -boot d -vga std
else
    echo -e "\"${OVMFPath}\" \033[31mfile does not exist .\033[0m"
fi
#UEFI
