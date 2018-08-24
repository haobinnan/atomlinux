#!/usr/bin/env bash

Make="make -j$(cat /proc/cpuinfo | grep "cpu cores" | wc -l)"

if [ ! -f ../../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_WestonVNumber="$(grep -i ^AtomLinux_WestonVNumber ../../VariableSetting | cut -f2 -d'=')"
AtomLinux_DownloadURL="$(grep -i ^AtomLinux_WestonURL ../../VariableSetting | cut -f2 -d'=')"
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ../../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

CurrentDIR=$(pwd)
OBJ_PROJECT=weston
FILENAME_DIR=${OBJ_PROJECT}-$AtomLinux_WestonVNumber

#Clean
function clean_weston()
{
    rm -f ./weston.ini
    rm -rf ./*-weston

    rm -rf ${OBJ_PROJECT}-tmp
}

if test $1 && [ $1 = "clean" ]; then
    clean_weston
    echo "weston clean ok!"
    exit
fi
#Clean

#Platform
ARCH=x86
if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    ARCH=x86_64
fi
#Platform

clean_weston
mkdir -p ${OBJ_PROJECT}-tmp/${FILENAME_DIR}
git clone --branch ${AtomLinux_WestonVNumber} ${AtomLinux_DownloadURL} ${OBJ_PROJECT}-tmp/${FILENAME_DIR}
cd ./${OBJ_PROJECT}-tmp/${FILENAME_DIR}

WESTONPARAM="--disable-setuid-install --disable-weston-launch --enable-fbdev-compositor --disable-x11-compositor --disable-drm-compositor --disable-wayland-compositor --disable-rdp-compositor --disable-headless-compositor --disable-egl --disable-xwayland"

#autogen
if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    ./autogen.sh --prefix=/usr ${WESTONPARAM}
else
    if [ $(getconf LONG_BIT) = '64' ]; then
        export PKG_CONFIG_PATH=/usr/lib/i386-linux-gnu/pkgconfig/
        ./autogen.sh --prefix=/usr ${WESTONPARAM} --build=i386-pc-linux-gnu "CFLAGS=-m32" "CXXFLAGS=-m32" "LDFLAGS=-m32"
        export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig/
    else
        ./autogen.sh --prefix=/usr ${WESTONPARAM}
    fi
fi
#autogen
#Check autogen
if [ ! $? -eq 0 ]; then
    echo "Error: autogen (weston) ."
    exit 1
fi
#Check autogen

echo | $Make
#Check make
if [ ! $? -eq 0 ]; then
    echo "Error: make (weston) ."
    exit 1
fi
#Check make

make install DESTDIR=${CurrentDIR}/${ARCH}-weston
#Check make install
if [ ! $? -eq 0 ]; then
    echo "Error: make install (weston) ."
    exit 1
fi
#Check make install
cp ./weston.ini ${CurrentDIR}/

cd ../../
rm -rf ${OBJ_PROJECT}-tmp

#Delete useless files
rm -rf ./${ARCH}-weston/usr/include
rm -rf ./${ARCH}-weston/usr/share/man
rm -rf ./${ARCH}-weston/usr/lib/pkgconfig
find ./${ARCH}-weston/usr/ -name '*.la' -type f -print -exec rm -rf {} \;
#Delete useless files

echo "Complete."
