#!/usr/bin/env bash

Make="make -j$(cat /proc/cpuinfo | grep "cpu cores" | wc -l)"

if [ ! -f ../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_QtVNumber4="$(grep -i ^AtomLinux_QtVNumber4 ../VariableSetting | cut -f2 -d'=')"
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ../VariableSetting | cut -f2 -d'=')"
AtomLinux_DownloadURL="$(grep -i ^AtomLinux_Qt4URL ../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

#Platform
MyArch=x86
MyPlatform=linux-g++-32
MpXPlatform=linux-x86-g++
MyEmbedded=x86
if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    MyArch=x86_64
    MyPlatform=linux-g++-64
    MpXPlatform=linux-x86_64-g++
    MyEmbedded=x86_64
fi
#Platform

DisableDebug_Emb=yes
DisableRelease_Emb=no
DisableDebug_Desktop=yes
DisableRelease_Desktop=no

CurrentDIR=$(pwd)
OBJ_PROJECT=qt

QtVNumber=$AtomLinux_QtVNumber4

FILENAME_DIR=qt-everywhere-opensource-src-${QtVNumber}
FILENAME=${FILENAME_DIR}.tar.gz

#Download Source Code
if [ ! -f ./${FILENAME} ]; then
    #Check if necessary tools are installed
    if [ -z $(which wget) ]; then
        echo "wget is not installed."
        exit 1
    fi
    #Check if necessary tools are installed
    wget ${AtomLinux_DownloadURL}${QtVNumber}/${FILENAME}
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

mkdir -p ${OBJ_PROJECT}-tmp/build_tmp
tar -xzvf ${FILENAME} -C ./${OBJ_PROJECT}-tmp/
#Check Decompression
if [ ! $? -eq 0 ]; then
    echo "Error: Decompression Qt ."
    exit 1
fi
#Check Decompression

#64bit system usage
if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
    if [ $(getconf LONG_BIT) = '64' ]; then
        sed -i '10i # modifications to g++.conf\nQMAKE_CFLAGS            += -m32\nQMAKE_CXXFLAGS          += -m32\nQMAKE_LFLAGS            += -m32\n' ./${OBJ_PROJECT}-tmp/${FILENAME_DIR}/mkspecs/qws/linux-x86-g++/qmake.conf
    fi
fi
#64bit system usage

#function
function build_Emb()
{
    VERSION=$1
    ARCH=${MyArch}_${VERSION}_Emb

    rm -rf ./${OBJ_PROJECT}-tmp/build_tmp/*
    cd ./${OBJ_PROJECT}-tmp/build_tmp/

    # make confclean
    mkdir ../../${ARCH}	
    echo yes | ../${FILENAME_DIR}/configure -prefix ${CurrentDIR}/${ARCH} \
    -make libs \
    -nomake demos \
    -nomake examples \
    -nomake docs \
    -nomake tools \
    -platform ${MyPlatform} \
    -xplatform qws/${MpXPlatform} \
    -embedded ${MyEmbedded} \
    -depths 16,18,24,32 \
    -no-gfx-qvfb \
    -qt-gfx-linuxfb \
    -no-gfx-transformed \
    -no-gfx-vnc \
    -no-gfx-multiscreen \
    -qt-kbd-tty \
    -${VERSION} \
    -opensource \
    -shared \
    -no-accessibility \
    -largefile \
    -fast \
    -no-sql-db2 -no-sql-ibase -no-sql-mysql -no-sql-oci -no-sql-odbc -no-sql-psql -no-sql-sqlite -no-sql-sqlite2 -no-sql-sqlite_symbian -no-sql-symsql -no-sql-tds \
    -no-qt3support \
    -no-xmlpatterns \
    -no-multimedia \
    -no-audio-backend \
    -no-phonon \
    -no-phonon-backend \
    -no-svg \
    -no-webkit \
    -no-javascript-jit \
    -no-script \
    -no-scripttools \
    -no-mmx -no-sse -no-sse2 -no-sse3 -no-ssse3 -no-sse4.1 -no-sse4.2 -no-3dnow -no-avx -no-neon \
    -qt-zlib -no-gif -no-libtiff -qt-libpng -no-libmng -qt-libjpeg \
    -no-nis -no-cups -no-iconv -no-icu \
    -no-openssl -no-nas-sound -no-opengl -no-openvg -no-sm -no-xshape -no-xvideo -no-xsync -no-xinerama -no-xcursor -no-xfixes -no-xrandr -no-xrender -no-xinput -no-glib -no-freetype
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

    cd ../../
}

function build_Desktop()
{
#
#	-make libs \
#	-nomake demos \
#	-nomake tools \
#	-nomake docs \
#
    VERSION=$1
    ARCH=${MyArch}_${VERSION}_Desktop

    rm -rf ./${OBJ_PROJECT}-tmp/build_tmp/*
    cd ./${OBJ_PROJECT}-tmp/build_tmp/

    # make confclean
    mkdir ../../${ARCH}
    echo yes | ../${FILENAME_DIR}/configure -prefix ${CurrentDIR}/${ARCH} \
    -nomake examples \
    -platform ${MyPlatform} \
    -${VERSION} \
    -opensource \
    -shared \
    -no-accessibility \
    -largefile \
    -fast \
    -no-sql-db2 -no-sql-ibase -no-sql-mysql -no-sql-oci -no-sql-odbc -no-sql-psql -no-sql-sqlite -no-sql-sqlite2 -no-sql-sqlite_symbian -no-sql-symsql -no-sql-tds \
    -no-qt3support \
    -no-xmlpatterns \
    -no-multimedia \
    -no-audio-backend \
    -no-phonon \
    -no-phonon-backend \
    -no-svg \
    -no-webkit \
    -no-javascript-jit \
    -no-script \
    -no-scripttools \
    -no-mmx -no-sse -no-sse2 -no-sse3 -no-ssse3 -no-sse4.1 -no-sse4.2 -no-3dnow -no-avx -no-neon \
    -qt-zlib -no-gif -no-libtiff -qt-libpng -no-libmng -qt-libjpeg \
    -no-nis -no-cups -no-iconv -no-icu \
    -no-openssl -no-nas-sound -no-opengl -no-openvg -no-sm -no-xshape -no-xvideo -no-xsync -no-xinerama -no-xcursor -no-xfixes -no-xrandr -no-xrender -no-xinput -no-glib \
    -fontconfig
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

    cd ../../
}
#function

if [ ${DisableDebug_Emb} != "yes" ]; then
    build_Emb debug
fi

echo "-------------------------------------------------------------"

if [ ${DisableRelease_Emb} != "yes" ]; then
    build_Emb release
fi

echo "-------------------------------------------------------------"

if [ ${DisableRelease_Desktop} != "yes" ]; then
    build_Desktop release
fi

echo "-------------------------------------------------------------"

if [ ${DisableDebug_Desktop} != "yes" ]; then
    build_Desktop debug
fi

rm -rf ${OBJ_PROJECT}-tmp

echo "Complete."
