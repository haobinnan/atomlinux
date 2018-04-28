#!/usr/bin/env bash

if [ ! -f ../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_GraphicsLibrary="$(grep -i ^AtomLinux_GraphicsLibrary ../VariableSetting | cut -f2 -d'=')"
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

rm -rf ./MyConfig/lib/*

iIndex=0

#Basic lib
if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    ArrayLib[$((iIndex++))]="/lib64/ld-linux-x86-64.so.2"
    ArrayLib[$((iIndex++))]="/lib/x86_64-linux-gnu/libc.so.6"
    ArrayLib[$((iIndex++))]="/lib/x86_64-linux-gnu/libm.so.6"
    ArrayLib[$((iIndex++))]="/lib/x86_64-linux-gnu/libdl.so.2"
    ArrayLib[$((iIndex++))]="/lib/x86_64-linux-gnu/libpthread.so.0"
else
    ArrayLib[$((iIndex++))]="/lib/ld-linux.so.2"
    ArrayLib[$((iIndex++))]="/lib/i386-linux-gnu/libc.so.6"
    ArrayLib[$((iIndex++))]="/lib/i386-linux-gnu/libm.so.6"
    ArrayLib[$((iIndex++))]="/lib/i386-linux-gnu/libdl.so.2"
    ArrayLib[$((iIndex++))]="/lib/i386-linux-gnu/libpthread.so.0"
fi
#Basic lib

#GraphicsLibrary
if [ ${AtomLinux_GraphicsLibrary} = "Qt" ]; then
    if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
        ArrayLib[$((iIndex++))]="/lib/x86_64-linux-gnu/librt.so.1"
        ArrayLib[$((iIndex++))]="/lib/x86_64-linux-gnu/libz.so.1"
        ArrayLib[$((iIndex++))]="/lib/x86_64-linux-gnu/libgcc_s.so.1"
        ArrayLib[$((iIndex++))]="/usr/lib/x86_64-linux-gnu/libstdc++.so.6"
    else
        ArrayLib[$((iIndex++))]="/lib/i386-linux-gnu/librt.so.1"
        ArrayLib[$((iIndex++))]="/lib/i386-linux-gnu/libz.so.1"
        ArrayLib[$((iIndex++))]="/lib/i386-linux-gnu/libgcc_s.so.1"
        ArrayLib[$((iIndex++))]="/usr/lib/i386-linux-gnu/libstdc++.so.6"
    fi
elif [ ${AtomLinux_GraphicsLibrary} = "Qt5" ]; then
    if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
        ArrayLib[$((iIndex++))]="/lib/x86_64-linux-gnu/librt.so.1"
        ArrayLib[$((iIndex++))]="/lib/x86_64-linux-gnu/libz.so.1"
        ArrayLib[$((iIndex++))]="/lib/x86_64-linux-gnu/libgcc_s.so.1"
        ArrayLib[$((iIndex++))]="/usr/lib/x86_64-linux-gnu/libstdc++.so.6"
        ArrayLib[$((iIndex++))]="/usr/lib/x86_64-linux-gnu/libdrm.so.2"
        ArrayLib[$((iIndex++))]="/usr/lib/x86_64-linux-gnu/libpng16.so.16"
    else
        ArrayLib[$((iIndex++))]="/lib/i386-linux-gnu/librt.so.1"
        ArrayLib[$((iIndex++))]="/lib/i386-linux-gnu/libz.so.1"
        ArrayLib[$((iIndex++))]="/lib/i386-linux-gnu/libgcc_s.so.1"
        ArrayLib[$((iIndex++))]="/usr/lib/i386-linux-gnu/libstdc++.so.6"
        ArrayLib[$((iIndex++))]="/usr/lib/i386-linux-gnu/libdrm.so.2"
        ArrayLib[$((iIndex++))]="/usr/lib/i386-linux-gnu/libpng16.so.16"
    fi
elif [ ${AtomLinux_GraphicsLibrary} = "Ncurses" ]; then
    if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
        :
    else
        :
    fi
fi
#GraphicsLibrary

#ArrayLib[$((iIndex++))]="/lib/i386-linux-gnu/libdbus-1.so.3"

for var in ${ArrayLib[@]};
do
    if [ -f $var ]; then
        cp -v $var ./MyConfig/lib/
    fi
done

#mv ld-linux to lib64
if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    mv -v ./MyConfig/lib/ld-linux* ./MyConfig/lib64/
fi
#mv ld-linux to lib64

echo "Complete."
