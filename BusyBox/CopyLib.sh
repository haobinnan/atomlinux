#!/usr/bin/env bash

if [ ! -f ../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_GraphicsLibrary="$(grep -i ^AtomLinux_GraphicsLibrary ../VariableSetting | cut -f2 -d'=')"
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ../VariableSetting | cut -f2 -d'=')"
AtomLinux_UsingWeston="$(grep -i ^AtomLinux_UsingWeston ../VariableSetting | cut -f2 -d'=')"
AtomLinux_UsingDislocker="$(grep -i ^AtomLinux_UsingDislocker ../VariableSetting | cut -f2 -d'=')"
AtomLinux_UsingDropbearSSH="$(grep -i ^AtomLinux_UsingDropbearSSH ../VariableSetting | cut -f2 -d'=')"
AtomLinux_UsingLibnss="$(grep -i ^AtomLinux_UsingLibnss ../VariableSetting | cut -f2 -d'=')"
AtomLinux_UsingLibefivar="$(grep -i ^AtomLinux_UsingLibefivar ../VariableSetting | cut -f2 -d'=')"
AtomLinux_UsingNtfs3g="$(grep -i ^AtomLinux_UsingNtfs3g ../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

#mkdir lib
if [ -d ./MyConfig/lib ]; then
    rm -rf ./MyConfig/lib/*
else
    mkdir ./MyConfig/lib
fi
if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    if [ -d ./MyConfig/lib64 ]; then
        rm -rf ./MyConfig/lib64/*
    else
        mkdir ./MyConfig/lib64
    fi
fi
if [ -d ./MyConfig/usr/lib ]; then
    rm -rf ./MyConfig/usr/lib/*
else
    mkdir -p ./MyConfig/usr/lib
fi
#mkdir lib

if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    Arch="x86_64"
else
    Arch="i386"
fi

iIndex=0

#Basic lib
if [ ${Arch} = "x86_64" ]; then
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/ld-*"
else
    ArrayLib[$((iIndex++))]="/lib/ld-*"
fi
ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libc.so.*"
ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libc-*.so*"
ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libm.so.*"
ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libm-*.so*"
ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libdl.so.*"
ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libdl-*.so*"
ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libpthread.so.*"
ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libpthread-*.so*"
ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libresolv.so.*"
ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libresolv-*.so*"
#Basic lib

#GraphicsLibrary
if [ ${AtomLinux_GraphicsLibrary} = "Qt" ]; then
#    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/librt.so.*"
#    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/librt-*.so*"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libz.so.*"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libgcc_s.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libstdc++.so.*"
elif [ ${AtomLinux_GraphicsLibrary} = "Qt5" ]; then
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libgcc_s.so.*"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libz.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libstdc++.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libdrm.so.*"
elif [ ${AtomLinux_GraphicsLibrary} = "Ncurses" ]; then
    :
fi
#GraphicsLibrary

#weston
if [ ${AtomLinux_UsingWeston} = "Yes" ]; then
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libudev.so.*"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libpcre.so.*"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libexpat.so.*"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libbsd.so.*"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libz.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libwayland-client.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libwayland-server.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libwayland-cursor.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libinput.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libevdev.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libpixman-1.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libxkbcommon.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libffi.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libmtdev.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libwacom.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libgudev-1.0.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libgobject-2.0.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libglib-2.0.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libcairo.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libpng16.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libjpeg.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libfontconfig.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libfreetype.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libxcb-shm.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libxcb.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libxcb-render.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libXrender.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libX11.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libXext.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libuuid.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libXau.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libXdmcp.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libdrm.so.*"
fi
#weston

#dislocker
if [ ${AtomLinux_UsingDislocker} = "Yes" ]; then
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libfuse.so.*"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libmbedcrypto.so.*"
fi
#dislocker

#Dropbear SSH
if [ ${AtomLinux_UsingDropbearSSH} = "Yes" ]; then
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libutil.so.*"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libutil-*.so*"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libcrypt.so.*"
fi
#Dropbear SSH

#ntfs-3g
if [ ${AtomLinux_UsingNtfs3g} = "Yes" ]; then
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libuuid.so.*"
fi
#ntfs-3g

#libnss
if [ ${AtomLinux_UsingLibnss} = "Yes" ]; then
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libnss_files.so.*"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libnss_files-*.so*"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libnss_dns.so.*"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libnss_dns-*.so*"
fi
#libnss

#libefivar
if [ ${AtomLinux_UsingLibefivar} = "Yes" ]; then
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libefivar.so*"
fi
#libefivar

for var in ${ArrayLib[@]};
do
    if [ -f $var ]; then
        if [ ${var:0:9} = "/usr/lib/" ]; then
            if [ ! -f ./MyConfig/usr/lib/${var##*/} ]; then
                cp -dv $var ./MyConfig/usr/lib/
            fi
        else
            if [ ! -f ./MyConfig/lib/${var##*/} ]; then
                cp -dv $var ./MyConfig/lib/
            fi
        fi
    fi
done

#mv ld-linux to lib64
if [ ${Arch} = "x86_64" ]; then
    mv -v ./MyConfig/lib/ld-* ./MyConfig/lib64/
fi
#mv ld-linux to lib64

echo "Complete."
