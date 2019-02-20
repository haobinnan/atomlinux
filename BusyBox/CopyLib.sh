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
AtomLinux_UsingLibnss="$(grep -i ^AtomLinux_UsingLibnss ../VariableSetting | cut -f2 -d'=')"
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
    ArrayLib[$((iIndex++))]="/lib64/ld-linux-x86-64.so.2"
else
    ArrayLib[$((iIndex++))]="/lib/ld-linux.so.2"
fi
ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libc.so.6"
ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libm.so.6"
ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libdl.so.2"
ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libpthread.so.0"
ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libresolv.so.2"
#Basic lib

#GraphicsLibrary
if [ ${AtomLinux_GraphicsLibrary} = "Qt" ]; then
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/librt.so.1"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libz.so.1"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libgcc_s.so.1"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libstdc++.so.6"
elif [ ${AtomLinux_GraphicsLibrary} = "Qt5" ]; then
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/librt.so.1"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libz.so.1"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libgcc_s.so.1"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libudev.so.1"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libpcre.so.3"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libbsd.so.0"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libstdc++.so.6"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libdrm.so.2"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libpng16.so.16"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libGL.so.1"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libharfbuzz.so.0"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libGLX.so.0"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libGLdispatch.so.0"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libglib-2.0.so.0"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libfreetype.so.6"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libgraphite2.so.3"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libX11.so.6"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libxcb.so.1"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libXau.so.6"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libXdmcp.so.6"
elif [ ${AtomLinux_GraphicsLibrary} = "Ncurses" ]; then
    :
fi
#GraphicsLibrary

#weston
if [ ${AtomLinux_UsingWeston} = "Yes" ]; then
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/librt.so.1"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libudev.so.1"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libpcre.so.3"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libexpat.so.1"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libz.so.1"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libbsd.so.0"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libwayland-server.so.0"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libwayland-client.so.0"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libwayland-cursor.so.0"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libinput.so.10"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libpixman-1.so.0"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libxkbcommon.so.0"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libffi.so.6"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libmtdev.so.1"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libevdev.so.2"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libwacom.so.2"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libgudev-1.0.so.0"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libgobject-2.0.so.0"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libglib-2.0.so.0"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libcairo.so.2"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libjpeg.so.8"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libfontconfig.so.1"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libxcb-shm.so.0"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libxcb-render.so.0"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libXrender.so.1"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libXext.so.6"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libpng16.so.16"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libfreetype.so.6"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libxcb.so.1"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libX11.so.6"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libXau.so.6"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libXdmcp.so.6"
fi
#weston

#dislocker
if [ ${AtomLinux_UsingDislocker} = "Yes" ]; then
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libfuse.so.2"
    ArrayLib[$((iIndex++))]="/lib/${Arch}-linux-gnu/libcrypt.so.1"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libmbedcrypto.so.1"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libruby-2.5.so.2.5"
    ArrayLib[$((iIndex++))]="/usr/lib/${Arch}-linux-gnu/libgmp.so.10"
fi
#dislocker

for var in ${ArrayLib[@]};
do
    if [ -f $var ]; then
        if [ ${var:0:9} = "/usr/lib/" ]; then
            if [ ! -f ./MyConfig/usr/lib/${var##*/} ]; then
                cp -v $var ./MyConfig/usr/lib/
            fi
        else
            if [ ! -f ./MyConfig/lib/${var##*/} ]; then
                cp -v $var ./MyConfig/lib/
            fi
        fi
    fi
done

#libnss
if [ ${AtomLinux_UsingLibnss} = "Yes" ]; then
    MyCopy="/lib/${Arch}-linux-gnu/libnss_files*"
    cp -dv ${MyCopy} ./MyConfig/lib/
    MyCopy="/lib/${Arch}-linux-gnu/libnss_dns*"
    cp -dv ${MyCopy} ./MyConfig/lib/
fi
#libnss

#mv ld-linux to lib64
if [ ${Arch} = "x86_64" ]; then
    mv -v ./MyConfig/lib/ld-linux* ./MyConfig/lib64/
fi
#mv ld-linux to lib64

echo "Complete."
