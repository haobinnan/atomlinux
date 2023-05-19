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
read -p "Do you want to execute apt update and apt dist-upgrade? [y/n]" answer
if [ -z "${answer}" ]; then
    answer="N"
fi
if [ $answer = "y" ] || [ $answer = "Y" ]; then
    if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
        if [ $(getconf LONG_BIT) = '64' ]; then
            sudo dpkg --add-architecture i386
        fi
    fi

    sudo apt update
    echo y | sudo apt dist-upgrade

    read -p "Update completed. Do you want to restart system? [y/n]" answer
    if [ -z "${answer}" ]; then
        answer="N"
    fi
    if [ $answer = "y" ] || [ $answer = "Y" ]; then
        sudo reboot
    fi
fi
#apt update

#function
function MyInstall_Base()
{
    echo y | sudo apt install $1
    #Check
    if [ ! $? -eq 0 ]; then
        echo "Error: apt install ."
        exit 1
    fi
    #Check
}

function MyInstall()
{
    INSTALL=$1
    if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
        if [ $(getconf LONG_BIT) = '64' ]; then
            INSTALL=${INSTALL// /:i386 }:i386
        fi
    fi
    MyInstall_Base "${INSTALL}"
}
#function

#tools
MyInstall_Base "wget vim git git-gui sbsigntool lcab python2 perl ruby flex bison cmake gperf pesign libnss3-tools openssl automake nasm autogen m4 autoconf autopoint help2man xorriso texinfo gettext upx-ucl dos2unix genisoimage bc"
MyInstall_Base "python3 python3-pip python3-setuptools python3-wheel"
#tools

MyInstall_Base "build-essential module-assistant gcc-multilib g++-multilib libtool libpcre3"

#meson
MyInstall_Base "ninja-build"
sudo pip3 install meson
#meson

MyInstall "libncurses5-dev zlib1g-dev libpng-dev libjpeg-dev libpcre3-dev libefivar-dev libwayland-dev"

#libssl
apt list libssl1.0-dev | egrep 'libssl1.0-dev'
if [ ! $? -eq 0 ]; then
    MyInstall "libssl-dev"
else
    MyInstall "libssl1.0-dev"
fi
#libssl

#What you need to build 'LinuxKernel'
MyInstall_Base "libelf-dev"
if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
    if [ $(getconf LONG_BIT) = '64' ]; then
        MyInstall_Base "libelf-dev:i386"
    fi
fi
#What you need to build 'LinuxKernel'

#What you need to build 'Qt4 x11 version'
MyInstall "libx11-dev libxext-dev libxtst-dev libfontconfig1-dev"
#What you need to build 'Qt4 x11 version'

#What you need to build 'Qt5'
#QDoc
MyInstall "libclang-dev"
#QDoc

# Libxcb
MyInstall "^libxcb.*-dev libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev"
# Libxcb

# Qt WebKit
MyInstall "libicu-dev libxslt1-dev"
# Qt WebKit

# Qt WebEngine
MyInstall "libxcursor-dev libxcomposite-dev libxdamage-dev libxrandr-dev libdbus-1-dev libfontconfig1-dev libcap-dev libxtst-dev libpulse-dev libudev-dev libpci-dev libnspr4-dev libnss3-dev libasound2-dev libxss-dev libegl1-mesa-dev"
MyInstall "libbz2-dev libgcrypt20-dev libdrm-dev libcupsimage2-dev libtiff-dev libcups2-dev libatkmm-1.6-dev"
# Qt WebEngine
#What you need to build 'Qt5'

#What you need to build 'grub2'
MyInstall_Base "libopts25 libfont-freetype-perl libopts25-dev libselinux1-dev autotools-dev libfreetype6-dev libdevmapper-dev libpciaccess-dev librpm-dev libfuse3-dev"
#What you need to build 'grub2'

#What you need to build 'weston'
MyInstall_Base "wayland-protocols"

MyInstall "libgles2-mesa-dev libxcb-composite0-dev libxcursor-dev libcairo2-dev libgbm-dev libpam0g-dev"
MyInstall "libinput-dev libxkbcommon-dev libxml2-dev"
#What you need to build 'weston'

#What you need to build 'dislocker'
MyInstall "libfuse-dev libmbedtls-dev ruby-dev"
#What you need to build 'dislocker'

#What you need to build 'OVMF'
MyInstall_Base "acpica-tools"

MyInstall_Base "libmount-dev"
if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
    if [ $(getconf LONG_BIT) = '64' ]; then
        MyInstall_Base "libmount-dev:i386"
    fi
fi
#What you need to build 'OVMF'

#What you need to build 'glib'
MyInstall "libffi-dev libfam-dev libmount-dev"
#What you need to build 'glib'

#Install qemu
MyInstall_Base "aqemu"
#Install qemu

echo y | sudo apt autoremove

echo "Complete."
