#!/usr/bin/env bash

if [ ! -f ./VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_InitramfsLinuxAppDirName="$(grep -i ^AtomLinux_InitramfsLinuxAppDirName ./VariableSetting | cut -f2 -d'=')"
AtomLinux_InitramfsLinuxAppFontDirName="$(grep -i ^AtomLinux_InitramfsLinuxAppFontDirName ./VariableSetting | cut -f2 -d'=')"
AtomLinux_LinuxSoftwareDirName="$(grep -i ^AtomLinux_LinuxSoftwareDirName ./VariableSetting | cut -f2 -d'=')"
AtomLinux_Grub2LdrName="$(grep -i ^AtomLinux_Grub2LdrName ./VariableSetting | cut -f2 -d'=')"
AtomLinux_InstallationPackageFileName="$(grep -i ^AtomLinux_InstallationPackageFileName ./VariableSetting | cut -f2 -d'=')"
AtomLinux_ISOName="$(grep -i ^AtomLinux_ISOName ./VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

rm -rf ./BusyBox/initramfs
rm -rf ./BusyBox/*_install
rm -rf ./BusyBox/iso_tmp
rm -rf ./BusyBox/$AtomLinux_InitramfsLinuxAppDirName
rm -rf ./BusyBox/$AtomLinux_InitramfsLinuxAppFontDirName
rm -rf ./BusyBox/$AtomLinux_LinuxSoftwareDirName
#MyConfig
rm -rf ./BusyBox/MyConfig/lib
rm -rf ./BusyBox/MyConfig/lib64
#MyConfig
rm -rf ./Grub2/i386-pc
rm -rf ./Grub2/efi-x86_64
rm -rf ./Grub2/efi-i386
rm -f ./Grub2/*.cfg
rm -f ./Grub2/${AtomLinux_Grub2LdrName}_cd
rm -rf ./Grub2/style
rm -rf ./Grub2/*.nosign
rm -rf ./LinuxKernel/x86
rm -rf ./LinuxKernel/x86_64
rm -rf ./LinuxKernel/*.nosign
rm -rf ./Ncurses/*-ncurses

#Qt4
rm -rf ./Qt/*_debug_*
rm -rf ./Qt/*_release_*
#Qt4

#Qt5
rm -rf ./Qt/*_release
#Qt5

rm -rf ./Lib/libiconv/*-libiconv
rm -rf ./Lib/glib/*-glib
rm -rf ./Utils/mdadm/*-mdadm
rm -f ./ovmf/OVMF*.fd
rm -f ./$AtomLinux_InstallationPackageFileName
rm -f ./$AtomLinux_ISOName
rm -rf Linux_sample

if [ ! -n "$1" ]; then
    echo "Do you want to clear source code compressed files downloaded during compiling? [y/n]"
    read answer
    if [ $answer = "y" ] || [ $answer = "Y" ]; then
        rm -f ./BusyBox/busybox-*.tar.bz2
        rm -f ./Lib/glib/glib-*.tar.xz
        rm -f ./Lib/libiconv/libiconv-*.tar.gz
        rm -f ./LinuxKernel/linux-*.tar.xz
        rm -f ./Ncurses/ncurses-*.tar.gz
        rm -f ./Qt/qt-everywhere-opensource-src-*.tar.gz
        rm -f ./Qt/qt-everywhere-opensource-src-*.tar.xz
        rm -f ./Utils/mdadm/mdadm-*.tar.xz
        rm -f ./ovmf/*.tar.gz
        rm -f ./Grub2/grub*.tar.*

        #shim
        rm -f ./shim/*.tar.gz
        rm -rf ./shim/shim_result
        rm -f ./shim/*.log
        #shim
    fi
fi

echo "Complete."
