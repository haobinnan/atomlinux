#!/usr/bin/env bash

sudo clear

if [ ! -f ../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

#apt update
echo "Do you want to execute apt update and apt dist-upgrade? [y/n]"
read answer
if [ $answer = "y" ] || [ $answer = "Y" ]; then
    if [ $(getconf LONG_BIT) = '64' ]; then
        sudo dpkg --add-architecture i386
    fi

    sudo apt update
    echo y | sudo apt dist-upgrade

    echo "Update completed. Do you want to restart system? [y/n]"
    read answer
    if [ $answer = "y" ] || [ $answer = "Y" ]; then
        sudo reboot
    fi
fi
#apt update

#tools
echo y | sudo apt install wget vim git git-gui sbsigntool lcab
#tools

echo y | sudo apt install build-essential module-assistant gcc-multilib g++-multilib libtool

echo y | sudo apt install libncurses5-dev zlib1g-dev libpng-dev libjpeg-dev libpcre3 libpcre3-dev libnss3-tools pesign
if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
    if [ $(getconf LONG_BIT) = '64' ]; then
        echo y | sudo apt install libncurses5-dev:i386 zlib1g-dev:i386 libpng-dev:i386 libjpeg-dev:i386 libpcre3-dev:i386
    fi
fi

#libssl
sudo apt list libssl1.0-dev | grep libssl1.0-dev -q
if [ ! $? -eq 0 ]; then
    echo y | sudo apt install libssl1.0-dev
    if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
        if [ $(getconf LONG_BIT) = '64' ]; then
            echo y | sudo apt install libssl1.0-dev:i386
        fi
    fi
else
    echo y | sudo apt install libssl-dev
    if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
        if [ $(getconf LONG_BIT) = '64' ]; then
            echo y | sudo apt install libssl-dev:i386
        fi
    fi
fi
#libssl

#What you need to build 'LinuxKernel'
echo y | sudo apt install libelf-dev
if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
    if [ $(getconf LONG_BIT) = '64' ]; then
        echo y | sudo apt install libelf-dev:i386
    fi
fi
#What you need to build 'LinuxKernel'

#What you need to build 'Qt4 x11 version'
echo y | sudo apt install libx11-dev libxext-dev libxtst-dev libfontconfig1-dev
if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
    if [ $(getconf LONG_BIT) = '64' ]; then
        echo y | sudo apt install libx11-dev:i386 libxext-dev:i386 libxtst-dev:i386 libfontconfig1-dev:i386
    fi
fi
#What you need to build 'Qt4 x11 version'

#What you need to build 'Qt5'
echo y | sudo apt install libxcb1 libxcb1-dev libx11-xcb1 libx11-xcb-dev libxcb-keysyms1 libxcb-keysyms1-dev libxcb-image0 libxcb-image0-dev libxcb-shm0 libxcb-shm0-dev libxcb-icccm4 libxcb-icccm4-dev libxcb-sync0-dev libxcb-xfixes0-dev libxrender-dev libxcb-shape0-dev libxcb-randr0-dev libxcb-render-util0 libxcb-render-util0-dev libxcb-glx0-dev libxcb-xinerama0 libxcb-xinerama0-dev
echo y | sudo apt install qt5-default
if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
    if [ $(getconf LONG_BIT) = '64' ]; then
        echo y | sudo apt install libxcb1-dev:i386 libx11-xcb-dev:i386 libxcb-keysyms1-dev:i386 libxcb-image0-dev:i386 libxcb-shm0-dev:i386 libxcb-icccm4-dev:i386 libxcb-sync0-dev:i386 libxcb-xfixes0-dev:i386 libxrender-dev:i386 libxcb-shape0-dev:i386 libxcb-randr0-dev:i386 libxcb-render-util0-dev:i386 libxcb-glx0-dev:i386 libxcb-xinerama0-dev:i386
        echo y | sudo apt install libxkbcommon-dev:i386 libmircommon-dev:i386 libmirclient-dev:i386 libegl1-mesa-dev:i386 libgles2-mesa-dev:i386 qtbase5-dev:i386
    fi
fi
#What you need to build 'Qt5'

#What you need to build 'grub2'
echo y | sudo apt install bison libopts25 libselinux1-dev autogen m4 autoconf help2man libopts25-dev flex libfont-freetype-perl automake autotools-dev libfreetype6-dev texinfo libdevmapper-dev libpciaccess-dev xorriso
#What you need to build 'grub2'

#What you need to build 'shim'
#   echo y | sudo apt install gnu-efi
#   echo y | sudo apt install gnu-efi:i386
#What you need to build 'shim'

#Install Qt Creator
echo y | sudo apt install qtcreator
#Install Qt Creator

#cmake
echo y | sudo apt install cmake
#cmake

#What you need to build 'glib'
echo y | sudo apt install libffi-dev libfam-dev libmount-dev gettext
if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
    if [ $(getconf LONG_BIT) = '64' ]; then
        echo y | sudo apt install libffi-dev:i386 libfam-dev:i386 libmount-dev:i386
    fi
fi
#What you need to build 'glib'

#Install qemu
echo y | sudo apt install qemu ovmf
#Install qemu

#Install upx
echo y | sudo apt install upx-ucl
#Install upx

./mk-install-gnu-efi.sh

echo "Complete."
