#!/usr/bin/env bash

Make="make -j$(cat /proc/cpuinfo | grep "cpu cores" | wc -l)"

if [ ! -f ../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_QtVNumber5="$(grep -i ^AtomLinux_QtVNumber5 ../VariableSetting | cut -f2 -d'=')"
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ../VariableSetting | cut -f2 -d'=')"
AtomLinux_DownloadURL="$(grep -i ^AtomLinux_Qt5URL ../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

#Platform
MyArch=x86
MyPlatform=linux-g++-32
if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    MyArch=x86_64
    MyPlatform=linux-g++-64
fi
#Platform

CurrentDIR=$(pwd)
OBJ_PROJECT=qt5

QtVNumber=$AtomLinux_QtVNumber5

FILENAME_DIR=qt-everywhere-opensource-src-${QtVNumber}
FILENAME=${FILENAME_DIR}.tar.xz

#Clean
function clean_qt5()
{
    rm -rf ./*_release

    rm -rf ${OBJ_PROJECT}-tmp
}

if test $1 && [ $1 = "clean" ]; then
    clean_qt5
    echo "qt5 clean ok!"
    exit
fi
#Clean

#Download Source Code
if [ ! -f ./${FILENAME} ]; then
    #Check if necessary tools are installed
    if [ -z $(which wget) ]; then
        echo "wget is not installed."
        exit 1
    fi
    #Check if necessary tools are installed
    wget ${AtomLinux_DownloadURL}${QtVNumber}/single/${FILENAME}
    if [ ! $? -eq 0 ]; then
        echo "Error: Download Qt ."
        exit 1
    fi
    #Check if it is downloaded successfully
    if [ ! -f ./${FILENAME} ]; then
        echo "Error: Download Qt ."
        exit 1
    fi
fi
#Download Source Code

VERSION=release
ARCH=${MyArch}_${VERSION}

clean_qt5
mkdir ${ARCH}
mkdir ${OBJ_PROJECT}-tmp

tar xvJf ./${FILENAME} -C ./${OBJ_PROJECT}-tmp
#Check Decompression
if [ ! $? -eq 0 ]; then
    echo "Error: Decompression Qt ."
    exit 1
fi
#Check Decompression

cd ./${OBJ_PROJECT}-tmp/${FILENAME_DIR}

# ***************** Compiling "opengl" and "qtwebengine" requires a large amount of memory (8GB). *****************

echo yes | ./configure -v -prefix ${CurrentDIR}/${ARCH} \
-${VERSION} \
-opensource -confirm-license -shared -optimize-size \
-no-icu -no-glib -no-cups -no-journald -no-fontconfig \
-qt-pcre -qt-libpng -qt-libjpeg -qt-freetype -qt-xkbcommon \
-xcb -evdev \
-skip qtwebengine \
-platform ${MyPlatform}
#-mtdev
#Check configure
if [ ! $? -eq 0 ]; then
    echo "Error: configure (Qt) ."
    exit 1
fi
#Check configure
echo | $Make
#Check make
if [ ! $? -eq 0 ]; then
    echo "Error: make (Qt) ."
    exit 1
fi
#Check make
make install
#Check make install
if [ ! $? -eq 0 ]; then
    echo "Error: make install (Qt) ."
    exit 1
fi
#Check make install

# Copy Font
cp -rv ./qtbase/lib/fonts ../../${ARCH}/lib
# Copy Font

# Install docs
make docs
#Check make docs
if [ ! $? -eq 0 ]; then
    echo "Error: make docs (Qt) ."
    exit 1
fi
#Check make docs
make install_docs
#Check make install_docs
if [ ! $? -eq 0 ]; then
    echo "Error: make install_docs (Qt) ."
    exit 1
fi
#Check make install_docs
# Install docs

cd ../../
rm -rf ${OBJ_PROJECT}-tmp
# echo "-------------------------------------------------------------"

echo "Complete."
