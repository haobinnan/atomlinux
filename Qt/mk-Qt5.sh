#!/usr/bin/env bash

Make="make -j$(cat /proc/cpuinfo | grep "cpu cores" | wc -l)"

if [ ! -f ../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_QtVNumber5="$(grep -i ^AtomLinux_QtVNumber5 ../VariableSetting | cut -f2 -d'=')"
AtomLinux_DownloadURL="$(grep -i ^AtomLinux_Qt5URL ../VariableSetting | cut -f2 -d'=')"
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ../VariableSetting | cut -f2 -d'=')"
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

FILENAME_DIR=qt-everywhere-src-${QtVNumber}
FILENAME=${FILENAME_DIR}.tar.xz

#Clean
function clean_qt5()
{
    rm -rf ./*_qt5_release

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
    if [ ! ${PIPESTATUS[0]} -eq 0 ]; then
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
ARCH=${MyArch}_qt5_${VERSION}

clean_qt5
mkdir ${ARCH}
mkdir ${OBJ_PROJECT}-tmp

tar xvJf ./${FILENAME} -C ./${OBJ_PROJECT}-tmp
#Check Decompression
if [ ! ${PIPESTATUS[0]} -eq 0 ]; then
    echo "Error: Decompression Qt ."
    exit 1
fi
#Check Decompression

function Get_LLVM_Install_DIR()
{
    LLVMPath="/usr/lib/"
    lsData=$(ls $LLVMPath)
    for filename in $lsData
    do
        if [[ $filename =~ "llvm-" ]]; then
            if [ -d $LLVMPath$filename/lib ] && [ -d $LLVMPath$filename/include ] && [ -d $LLVMPath$filename/bin ]; then
                export LLVM_INSTALL_DIR=$LLVMPath$filename
                break
            fi
        fi
    done
}

Get_LLVM_Install_DIR

cd ./${OBJ_PROJECT}-tmp/${FILENAME_DIR}

# ***************** Compiling "opengl" and "qtwebengine" requires a large amount of memory. *****************

# ****** Desktop ******

# echo yes | ./configure -v -prefix ${CurrentDIR}/${ARCH} \
# -${VERSION} \
# -opensource -confirm-license -shared \
# -no-icu -no-glib -no-cups -no-journald \
# -qt-pcre -qt-libpng -qt-libjpeg \
# -xcb -proprietary-codecs \
# -platform ${MyPlatform}

# ****** Desktop ******

./configure -v -prefix ${CurrentDIR}/${ARCH} \
-${VERSION} \
-opensource -confirm-license -shared -optimize-size \
-no-icu -no-glib -no-cups -no-journald -no-fontconfig -no-dbus -no-mtdev -no-tslib -no-libudev -no-opengl -no-egl -no-pulseaudio -no-alsa -no-gstreamer -no-libinput \
-qt-pcre -qt-libpng -qt-libjpeg -qt-freetype -qt-harfbuzz \
-xkbcommon -evdev \
-xcb -linuxfb -kms \
-skip qtwebengine \
-platform ${MyPlatform} 2>&1 | tee ${CurrentDIR}/${ARCH}/configure.log
#Check configure
if [ ! ${PIPESTATUS[0]} -eq 0 ]; then
    echo "Error: configure (Qt) ."
    exit 1
fi
#Check configure
echo | $Make | tee ${CurrentDIR}/${ARCH}/make.log
#Check make
if [ ! ${PIPESTATUS[0]} -eq 0 ]; then
    echo "Error: make (Qt) ."
    exit 1
fi
#Check make
make install | tee ${CurrentDIR}/${ARCH}/make_install.log
#Check make install
if [ ! ${PIPESTATUS[0]} -eq 0 ]; then
    echo "Error: make install (Qt) ."
    exit 1
fi
#Check make install

# Copy Font
cp -rv ./qtbase/lib/fonts ../../${ARCH}/lib
# Copy Font

# Install docs
make docs | tee ${CurrentDIR}/${ARCH}/make_docs.log
#Check make docs
if [ ! ${PIPESTATUS[0]} -eq 0 ]; then
    echo "Error: make docs (Qt) ."
    exit 1
fi
#Check make docs
make install_docs | tee ${CurrentDIR}/${ARCH}/make_docs_install.log
#Check make install_docs
if [ ! ${PIPESTATUS[0]} -eq 0 ]; then
    echo "Error: make install_docs (Qt) ."
    exit 1
fi
#Check make install_docs
# Install docs

cd ../../
rm -rf ${OBJ_PROJECT}-tmp
# echo "-------------------------------------------------------------"

echo "Complete."
