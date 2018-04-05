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
qemu-system-x86_64 -bios "OVMF.fd" -m 256M -cdrom ${AtomLinux_ISOName} -boot d -vga std
#UEFI
