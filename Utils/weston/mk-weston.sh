#!/usr/bin/env bash

# Make="make -j$(cat /proc/cpuinfo | grep "cpu cores" | wc -l)"

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
    rm -rf ./*-${OBJ_PROJECT}

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
# cp -r ./${FILENAME_DIR} ./${OBJ_PROJECT}-tmp
cd ./${OBJ_PROJECT}-tmp/${FILENAME_DIR}

WESTONPARAM="-Dlauncher-logind=false -Dcolor-management-colord=false -Dremoting=false -Dpipewire=false -Dcolor-management-lcms=false"

WESTONPARAM=${WESTONPARAM}" -Dbackend-fbdev=true -Dbackend-drm=true -Dbackend-default=fbdev -Dbackend-x11=false -Dbackend-headless=false -Dbackend-drm-screencast-vaapi=false -Dbackend-rdp=false -Dbackend-wayland=false -Drenderer-gl=false -Dxwayland=false -Dscreenshare=false -Dweston-launch=false -Dsystemd=false -Dimage-webp=false -Ddemo-clients=false -Dwcap-decode=false -Dsimple-clients=`` -Dtools=``"

#meson
if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    meson _build --prefix=/usr ${WESTONPARAM}
else
    if [ $(getconf LONG_BIT) = '64' ]; then
        meson _build --prefix=/usr ${WESTONPARAM} --cross-file ../../meson_x86-linux
    else
        meson _build --prefix=/usr ${WESTONPARAM}
    fi
fi
#meson
#Check meson
if [ ! $? -eq 0 ]; then
    echo "Error: meson (weston) ."
    exit 1
fi
#Check meson

ninja -C _build
#Check ninja
if [ ! $? -eq 0 ]; then
    echo "Error: ninja (weston) ."
    exit 1
fi
#Check ninja

DESTDIR=${CurrentDIR}/${ARCH}-${OBJ_PROJECT} ninja -C _build install
#Check ninja install
if [ ! $? -eq 0 ]; then
    echo "Error: ninja install (weston) ."
    exit 1
fi
#Check ninja install

#weston.ini
sed -i 's/--backend=rdp-backend.so/--backend=fbdev-backend.so/' ./_build/compositor/weston.ini
cp ./_build/compositor/weston.ini ${CurrentDIR}/
#weston.ini

cd ../../
rm -rf ${OBJ_PROJECT}-tmp

#Delete useless files
rm -rf ./${ARCH}-${OBJ_PROJECT}/usr/include
rm -rf ./${ARCH}-${OBJ_PROJECT}/usr/share/man
rm -rf ./${ARCH}-${OBJ_PROJECT}/usr/share/pkgconfig
rm -rf ./${ARCH}-${OBJ_PROJECT}/usr/lib/${ARCH}-linux-gnu/pkgconfig
# find ./${ARCH}-${OBJ_PROJECT}/usr/ -name '*.la' -type f -print -exec rm -rf {} \;
#Delete useless files

echo "Complete."
