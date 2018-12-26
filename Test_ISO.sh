#!/usr/bin/env bash

if [ ! -f ./VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_ISOName="$(grep -i ^AtomLinux_ISOName ./VariableSetting | cut -f2 -d'=')"
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ./VariableSetting | cut -f2 -d'=')"
AtomLinux_SecureBootSignature="$(grep -i ^AtomLinux_SecureBootSignature ./VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

QEMURunParameter="-smp 2 -m 256M -vga qxl -cdrom ${AtomLinux_ISOName} -boot d -net nic,model=e1000 -net user"
if [ -c /dev/kvm ]; then
    QEMURunParameter=${QEMURunParameter}" -enable-kvm"
else
    echo -e "\033[31mKVM is not supported.\033[0m"
fi

#Legacy BIOS
if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
    echo -e "\033[31mPlatform: 32-Bit(Legacy BIOS)\033[0m"
    sudo qemu-system-i386 ${QEMURunParameter}
fi
if [ $(getconf LONG_BIT) = '64' ]; then
    echo -e "\033[31mPlatform: 64-Bit(Legacy BIOS)\033[0m"
    sudo qemu-system-x86_64 ${QEMURunParameter}
fi
#Legacy BIOS

#UEFI BIOS
# 32Bit
OVMFPath="./ovmf/OVMF_IA32.fd"
if [ -f ${OVMFPath} ]; then
    if [ $(getconf LONG_BIT) = '64' ]; then
        if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
            echo -e "\033[31mPlatform: 32-Bit(32Bit UEFI BIOS)\033[0m"
            sudo qemu-system-i386 ${QEMURunParameter} -bios ${OVMFPath}
        fi
        if [ ${AtomLinux_SecureBootSignature} = "Yes" ]; then
            echo -e "\033[31mPlatform: 64-Bit(32Bit UEFI BIOS ** Secure Boot **)\033[0m"
            sudo qemu-system-x86_64 ${QEMURunParameter} -drive file=${OVMFPath},if=pflash,format=raw,unit=0,readonly=off
        fi

        echo -e "\033[31mPlatform: 64-Bit(32Bit UEFI BIOS)\033[0m"
        sudo qemu-system-x86_64 ${QEMURunParameter} -bios ${OVMFPath}
    else
        echo -e "\033[31mPlatform: 32-Bit(32Bit UEFI BIOS)\033[0m"
        sudo qemu-system-i386 ${QEMURunParameter} -bios ${OVMFPath}
    fi
else
    echo -e "\"${OVMFPath}\" \033[31mfile does not exist .\033[0m"
fi
# 32Bit

# 64Bit
if [ $(getconf LONG_BIT) = '64' ]; then
    OVMFPath="./ovmf/OVMF_X64.fd"
    if [ -f ${OVMFPath} ]; then
        if [ ${AtomLinux_SecureBootSignature} = "Yes" ]; then
            echo -e "\033[31mPlatform: 64-Bit(64Bit UEFI BIOS ** Secure Boot **)\033[0m"
            sudo qemu-system-x86_64 ${QEMURunParameter} -drive file=${OVMFPath},if=pflash,format=raw,unit=0,readonly=off
        fi

        echo -e "\033[31mPlatform: 64-Bit(64Bit UEFI BIOS)\033[0m"
        sudo qemu-system-x86_64 ${QEMURunParameter} -bios ${OVMFPath}
    else
        echo -e "\"${OVMFPath}\" \033[31mfile does not exist .\033[0m"
    fi
fi
# 64Bit
#UEFI BIOS
