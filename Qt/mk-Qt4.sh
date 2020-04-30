#!/usr/bin/env bash

Make="make -j$(cat /proc/cpuinfo | grep "cpu cores" | wc -l)"

if [ ! -f ../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_QtVNumber4="$(grep -i ^AtomLinux_QtVNumber4 ../VariableSetting | cut -f2 -d'=')"
AtomLinux_DownloadURL="$(grep -i ^AtomLinux_Qt4URL ../VariableSetting | cut -f2 -d'=')"
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

#Platform
MyArch=x86
MyPlatform=linux-g++-32
MyXPlatform=linux-x86-g++
MyEmbedded=x86
if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    MyArch=x86_64
    MyPlatform=linux-g++-64
    MyXPlatform=linux-x86_64-g++
    MyEmbedded=x86_64
fi
#Platform

SetStandard=no

DisableDebug_Emb=yes
DisableRelease_Emb=no
DisableDebug_Desktop=yes
DisableRelease_Desktop=no
DisableRelease_qvfb=yes

CurrentDIR=$(pwd)
OBJ_PROJECT=qt

QtVNumber=$AtomLinux_QtVNumber4

FILENAME_DIR=qt-everywhere-opensource-src-${QtVNumber}
FILENAME=${FILENAME_DIR}.tar.gz

#Clean
function clean_qt4()
{
    rm -rf ./*_debug_*
    rm -rf ./*_release_*

    rm -rf ${OBJ_PROJECT}-tmp
}

if test $1 && [ $1 = "clean" ]; then
    clean_qt4
    echo "qt4 clean ok!"
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

clean_qt4
mkdir -p ${OBJ_PROJECT}-tmp/build_tmp
tar -xzvf ${FILENAME} -C ./${OBJ_PROJECT}-tmp/
#Check Decompression
if [ ! $? -eq 0 ]; then
    echo "Error: Decompression Qt ."
    exit 1
fi
#Check Decompression

#Patches
cd ./${OBJ_PROJECT}-tmp/${FILENAME_DIR}/
if [ -d ../../Patches_Qt4 ]; then
    for file in $(ls ../../Patches_Qt4);
    do
        echo -e "\033[31m$file\033[0m"
        patch -p1 < ../../Patches_Qt4/$file
        #Check patch
        if [ ! $? -eq 0 ]; then
            echo "Error: patch (qt4) ."
            exit 1
        fi
        #Check patch
    done
fi
cd ../../
#Patches

#64bit system usage
if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
    if [ $(getconf LONG_BIT) = '64' ]; then
        sed -i '10i # modifications to g++.conf\nQMAKE_CFLAGS            += -m32\nQMAKE_CXXFLAGS          += -m32\nQMAKE_LFLAGS            += -m32\n' ./${OBJ_PROJECT}-tmp/${FILENAME_DIR}/mkspecs/qws/linux-x86-g++/qmake.conf
    fi
fi
#64bit system usage

#-std=gnu++98
function SetStandard()
{
    LN=`grep -n "load(qt_config)" $1| awk -F"[:]" '{print $1}'`
    sed ${LN-1}' iQMAKE_CXXFLAGS = $$QMAKE_CFLAGS -std=gnu++98' -i $1
}

if [ ${SetStandard} = "yes" ]; then
    SetStandard ./${OBJ_PROJECT}-tmp/${FILENAME_DIR}/mkspecs/linux-g++-32/qmake.conf
    SetStandard ./${OBJ_PROJECT}-tmp/${FILENAME_DIR}/mkspecs/linux-g++-64/qmake.conf
    SetStandard ./${OBJ_PROJECT}-tmp/${FILENAME_DIR}/mkspecs/qws/linux-x86-g++/qmake.conf
    SetStandard ./${OBJ_PROJECT}-tmp/${FILENAME_DIR}/mkspecs/qws/linux-x86_64-g++/qmake.conf
fi
#-std=gnu++98

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
    -xplatform qws/${MyXPlatform} \
    -embedded ${MyEmbedded} \
    -depths all \
    -no-gfx-qvfb \
    -qt-gfx-linuxfb \
    -qt-gfx-transformed \
    -qt-gfx-vnc \
    -qt-gfx-multiscreen \
    -qt-kbd-tty \
    -${VERSION} \
    -opensource \
    -shared \
    -no-accessibility \
    -largefile \
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

function build_qvfb()
{
    VERSION=$1
    ARCH=${MyArch}_${VERSION}_qvfb

    rm -rf ./${OBJ_PROJECT}-tmp/build_tmp/*
    cd ./${OBJ_PROJECT}-tmp/build_tmp/

    # make confclean
    mkdir ../../${ARCH}
    echo yes | ../${FILENAME_DIR}/configure -prefix ${CurrentDIR}/${ARCH} \
    -make libs \
    -make tools \
    -nomake demos \
    -nomake examples \
    -nomake docs \
    -platform ${MyPlatform} \
    -xplatform qws/${MyXPlatform} \
    -embedded ${MyEmbedded} \
    -qt-gfx-qvfb -qt-kbd-qvfb -qt-mouse-qvfb \
    -${VERSION} \
    -opensource \
    -shared \
    -no-accessibility \
    -largefile \
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
    -qt-zlib -no-gif -no-libtiff -qt-libpng -no-libmng -qt-libjpeg \
    -no-nis -no-cups -no-iconv -no-icu \
    -no-openssl -no-nas-sound -no-opengl -no-openvg -no-sm -no-xshape -no-xvideo -no-xsync -no-xinerama -no-xcursor -no-xfixes -no-xrandr -no-xrender -no-xinput -no-glib
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

    #qvfb
    cd tools/qvfb/
    echo | $Make
    #Check make qvfb
    if [ ! $? -eq 0 ]; then
        echo "Error: make qvfb (Qt) ."
        exit 1
    fi
    #Check make qvfb
    cp -v ../../bin/qvfb ${CurrentDIR}/${ARCH}/bin/
    cd ../../
    #qvfb

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

echo "-------------------------------------------------------------"

if [ ${DisableRelease_qvfb} != "yes" ]; then
    build_qvfb release
fi

rm -rf ${OBJ_PROJECT}-tmp

echo "Complete."
