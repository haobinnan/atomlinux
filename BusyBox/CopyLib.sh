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
ArrayLib[$((iIndex++))]="/lib/"${Arch}"-linux-gnu/libc.so.6"
ArrayLib[$((iIndex++))]="/lib/"${Arch}"-linux-gnu/libm.so.6"
ArrayLib[$((iIndex++))]="/lib/"${Arch}"-linux-gnu/libdl.so.2"
ArrayLib[$((iIndex++))]="/lib/"${Arch}"-linux-gnu/libpthread.so.0"
#Basic lib

#GraphicsLibrary
if [ ${AtomLinux_GraphicsLibrary} = "Qt" ]; then
    ArrayLib[$((iIndex++))]="/lib/"${Arch}"-linux-gnu/librt.so.1"
    ArrayLib[$((iIndex++))]="/lib/"${Arch}"-linux-gnu/libz.so.1"
    ArrayLib[$((iIndex++))]="/lib/"${Arch}"-linux-gnu/libgcc_s.so.1"
    ArrayLib[$((iIndex++))]="/usr/lib/"${Arch}"-linux-gnu/libstdc++.so.6"
elif [ ${AtomLinux_GraphicsLibrary} = "Qt5" ]; then
    ArrayLib[$((iIndex++))]="/lib/"${Arch}"-linux-gnu/librt.so.1"
    ArrayLib[$((iIndex++))]="/lib/"${Arch}"-linux-gnu/libz.so.1"
    ArrayLib[$((iIndex++))]="/lib/"${Arch}"-linux-gnu/libgcc_s.so.1"
    ArrayLib[$((iIndex++))]="/usr/lib/"${Arch}"-linux-gnu/libstdc++.so.6"
    ArrayLib[$((iIndex++))]="/usr/lib/"${Arch}"-linux-gnu/libdrm.so.2"
    ArrayLib[$((iIndex++))]="/usr/lib/"${Arch}"-linux-gnu/libpng16.so.16"
elif [ ${AtomLinux_GraphicsLibrary} = "Ncurses" ]; then
    :
fi
#GraphicsLibrary

#ArrayLib[$((iIndex++))]="/lib/"${Arch}"-linux-gnu/libdbus-1.so.3"

for var in ${ArrayLib[@]};
do
    if [ -f $var ]; then
        cp -v $var ./MyConfig/lib/
    fi
done

#mv ld-linux to lib64
if [ ${Arch} = "x86_64" ]; then
    mv -v ./MyConfig/lib/ld-linux* ./MyConfig/lib64/
fi
#mv ld-linux to lib64

echo "Complete."
