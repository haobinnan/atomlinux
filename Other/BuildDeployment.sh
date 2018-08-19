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
echo y | sudo apt install wget vim git git-gui sbsigntool lcab python perl ruby flex bison cmake gperf pesign automake nasm autogen m4 autoconf meson help2man xorriso texinfo gettext upx-ucl irpas
#tools

echo y | sudo apt install build-essential module-assistant gcc-multilib g++-multilib libtool libnss3-tools libpcre3

echo y | sudo apt install libncurses5-dev zlib1g-dev libpng-dev libjpeg-dev libpcre3-dev
if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
    if [ $(getconf LONG_BIT) = '64' ]; then
        echo y | sudo apt install libncurses5-dev:i386 zlib1g-dev:i386 libpng-dev:i386 libjpeg-dev:i386 libpcre3-dev:i386
    fi
fi

#libssl
apt list libssl1.0-dev | egrep 'libssl1.0-dev'
if [ ! $? -eq 0 ]; then
    echo y | sudo apt install libssl-dev
    if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
        if [ $(getconf LONG_BIT) = '64' ]; then
            echo y | sudo apt install libssl-dev:i386
        fi
    fi
else
    echo y | sudo apt install libssl1.0-dev
    if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
        if [ $(getconf LONG_BIT) = '64' ]; then
            echo y | sudo apt install libssl1.0-dev:i386
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
# Libxcb
echo y | sudo apt install '^libxcb.*-dev' libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev
# Libxcb

# Qt WebKit
echo y | sudo apt install libicu-dev libxslt1-dev
# Qt WebKit

# Qt WebEngine	
echo y | sudo apt install libxcursor-dev libxcomposite-dev libxdamage-dev libxrandr-dev libdbus-1-dev libfontconfig1-dev libcap-dev libxtst-dev libpulse-dev libudev-dev libpci-dev libnspr4-dev libnss3-dev libasound2-dev libxss-dev libegl1-mesa-dev
echo y | sudo apt install libbz2-dev libgcrypt11-dev libdrm-dev libcupsimage2-dev libtiff-dev libcups2-dev libatkmm-1.6-dev
# Qt WebEngine

if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
    if [ $(getconf LONG_BIT) = '64' ]; then
        # Libxcb
        echo y | sudo apt install '^libxcb.*-dev:i386' libx11-xcb-dev:i386 libglu1-mesa-dev:i386 libxrender-dev:i386 libxi-dev:i386
        # Libxcb

        # Qt WebKit
        echo y | sudo apt install libicu-dev:i386 libxslt1-dev:i386
        # Qt WebKit

        # Qt WebEngine	
        echo y | sudo apt install libxcursor-dev:i386 libxcomposite-dev:i386 libxdamage-dev:i386 libxrandr-dev:i386 libdbus-1-dev:i386 libfontconfig1-dev:i386 libcap-dev:i386 libxtst-dev:i386 libpulse-dev:i386 libudev-dev:i386 libpci-dev:i386 libnspr4-dev:i386 libnss3-dev:i386 libasound2-dev:i386 libxss-dev:i386 libegl1-mesa-dev:i386
        echo y | sudo apt install libbz2-dev:i386 libgcrypt11-dev:i386 libdrm-dev:i386 libcupsimage2-dev:i386 libtiff-dev:i386 libcups2-dev:i386 libatkmm-1.6-dev:i386
        # Qt WebEngine
    fi
fi
#What you need to build 'Qt5'

#What you need to build 'grub2'
echo y | sudo apt install libopts25 libfont-freetype-perl libopts25-dev libselinux1-dev autotools-dev libfreetype6-dev libdevmapper-dev libpciaccess-dev librpm-dev
#What you need to build 'grub2'

#What you need to build 'weston'
echo y | sudo apt install wayland-protocols

echo y | sudo apt install libgles2-mesa-dev libxcb-composite0-dev libxcursor-dev libcairo2-dev libgbm-dev libpam0g-dev
echo y | sudo apt install libinput-dev libxkbcommon-dev libxml2-dev
if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
    if [ $(getconf LONG_BIT) = '64' ]; then
        echo y | sudo apt install libgles2-mesa-dev:i386 libxcb-composite0-dev:i386 libxcursor-dev:i386 libcairo2-dev:i386 libgbm-dev:i386 libpam0g-dev:i386
        echo y | sudo apt install libinput-dev:i386 libxkbcommon-dev:i386 libxml2-dev:i386
    fi
fi
#What you need to build 'weston'

#What you need to build 'OVMF'
echo y | sudo apt install acpica-tools
#What you need to build 'OVMF'

#Install Qt Creator
echo y | sudo apt install qtcreator
#Install Qt Creator

#What you need to build 'glib'
echo y | sudo apt install libffi-dev libfam-dev libmount-dev
if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
    if [ $(getconf LONG_BIT) = '64' ]; then
        echo y | sudo apt install libffi-dev:i386 libfam-dev:i386 libmount-dev:i386
    fi
fi
#What you need to build 'glib'

#Install qemu
echo y | sudo apt install qemu
#Install qemu

echo y | sudo apt autoremove

./mk-install-gnu-efi.sh

echo "Complete."
