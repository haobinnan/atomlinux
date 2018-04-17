#!/usr/bin/env bash

sudo clear

if [ ! -f ../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_GraphicsLibrary="$(grep -i ^AtomLinux_GraphicsLibrary ../VariableSetting | cut -f2 -d'=')"
AtomLinux_InstallationPackageFileName="$(grep -i ^AtomLinux_InstallationPackageFileName ../VariableSetting | cut -f2 -d'=')"
AtomLinux_Grub2DirName="$(grep -i ^AtomLinux_Grub2DirName ../VariableSetting | cut -f2 -d'=')"
AtomLinux_LinuxSoftwareDirName="$(grep -i ^AtomLinux_LinuxSoftwareDirName ../VariableSetting | cut -f2 -d'=')"
AtomLinux_Grub2StyleDirName="$(grep -i ^AtomLinux_Grub2StyleDirName ../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

./mk-Bale.sh
#Check
if [ ! $? -eq 0 ]; then
    echo "Error: mk-Bale.sh ."
    exit 1
fi
#Check

RAMDISK_NAME=initramfs
sudo umount -n ../mnt
sudo rm -rf ../mnt
rm ../$AtomLinux_InstallationPackageFileName
rm ../Linux_sample/${RAMDISK_NAME}
cp -v ./${RAMDISK_NAME} ../Linux_sample/
cp -v ../Grub2/MBR/grubmbr ../Linux_sample/

#Update file of Linux_sample
rm -rf ../Linux_sample/$AtomLinux_LinuxSoftwareDirName
if [ $(ls ./$AtomLinux_LinuxSoftwareDirName/ -A $1|wc -w | awk '{print int($0)}') -gt 0 ]; then
    mkdir ../Linux_sample/$AtomLinux_LinuxSoftwareDirName
    cp -rRv ./$AtomLinux_LinuxSoftwareDirName/* ../Linux_sample/$AtomLinux_LinuxSoftwareDirName/
fi
rm -rf ../Linux_sample/${AtomLinux_Grub2DirName}/${AtomLinux_Grub2StyleDirName}/
rm -rf ../Linux_sample/${AtomLinux_Grub2DirName}
if [ $(ls ../Grub2/style -A $1|wc -w | awk '{print int($0)}') -gt 0 ]; then
    mkdir -p ../Linux_sample/${AtomLinux_Grub2DirName}/${AtomLinux_Grub2StyleDirName}/
    cp -rv ../Grub2/style/* ../Linux_sample/${AtomLinux_Grub2DirName}/${AtomLinux_Grub2StyleDirName}/
fi
#Update file of Linux_sample

#Ncurses
if [ ${AtomLinux_GraphicsLibrary} = "Ncurses" ]; then
    rm -rf ../Linux_sample/${AtomLinux_Grub2DirName}/${AtomLinux_Grub2StyleDirName}/
    rm -rf ../Linux_sample/${AtomLinux_Grub2DirName}
fi
#Ncurses

initramfsImgSize=$(du -sm ../Linux_sample | awk '{print int($0)}')
dd if=/dev/zero of=../$AtomLinux_InstallationPackageFileName bs=1M count=${initramfsImgSize}
sudo mkdir ../mnt
sudo mkfs.vfat ../$AtomLinux_InstallationPackageFileName
sudo mount -t vfat -n ../$AtomLinux_InstallationPackageFileName ../mnt
sudo cp -rRv ../Linux_sample/* ../mnt/
sudo umount -n ../mnt
sudo rm -rf ../mnt

echo "Complete."
