#!/usr/bin/env bash

sudo clear

echo -e "\033[31m-----------------------------\033[0m"
echo -e "\033[34mDescription\033[0m"
echo ""
echo -e "\033[33mRun EnrollDefaultKeys.efi\033[0m"
echo ""
echo -e "\033[33mShell> fs0:\033[0m"
echo -e "\033[33mFS0:\> EnrollDefaultKeys.efi\033[0m"
echo -e "\033[31m-----------------------------\033[0m"
echo ""
echo "Press Enter to continue."

read answer

QEMURunParameter="-smp 2 -m 256M -vga qxl -drive format=raw,file=./EnrollDefaultKeys.img"
if [ -c /dev/kvm ]; then
    QEMURunParameter=${QEMURunParameter}" -enable-kvm"
else
    echo -e "\033[31mKVM is not supported.\033[0m"
fi

# 32Bit
OVMFPath="./OVMF_IA32.fd"
if [ -f ${OVMFPath} ]; then
    if [ $(getconf LONG_BIT) = '64' ]; then
        echo -e "\033[31mCurrent: ${OVMFPath}\033[0m"
        sudo qemu-system-x86_64 ${QEMURunParameter} -drive file=${OVMFPath},if=pflash,format=raw,unit=0,readonly=off
    else
        echo -e "\033[31mCurrent: ${OVMFPath}\033[0m"
        sudo qemu-system-i386 ${QEMURunParameter} -drive file=${OVMFPath},if=pflash,format=raw,unit=0,readonly=off
    fi
else
    echo -e "\"${OVMFPath}\" \033[31mfile does not exist .\033[0m"
fi
# 32Bit

# 64Bit
if [ $(getconf LONG_BIT) = '64' ]; then
    OVMFPath="./OVMF_X64.fd"
    if [ -f ${OVMFPath} ]; then
        echo -e "\033[31mCurrent: ${OVMFPath}\033[0m"
        sudo qemu-system-x86_64 ${QEMURunParameter} -drive file=${OVMFPath},if=pflash,format=raw,unit=0,readonly=off
    else
        echo -e "\"${OVMFPath}\" \033[31mfile does not exist .\033[0m"
    fi
fi
# 64Bit

echo "Complete."
