#!/usr/bin/env bash

Make="make -j$(cat /proc/cpuinfo | grep "cpu cores" | wc -l)"

if [ ! -f ../../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_DislockerVNumber="$(grep -i ^AtomLinux_DislockerVNumber ../../VariableSetting | cut -f2 -d'=')"
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ../../VariableSetting | cut -f2 -d'=')"
AtomLinux_DownloadURL="$(grep -i ^AtomLinux_DislockerURL ../../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

OBJ_PROJECT=dislocker
FILENAME_DIR=${OBJ_PROJECT}-$AtomLinux_DislockerVNumber
FILENAME=${FILENAME_DIR}.tar.gz

#Clean
function clean_dislocker()
{
    rm -rf ./*-${OBJ_PROJECT}

    rm -rf ${OBJ_PROJECT}-tmp
}

if test $1 && [ $1 = "clean" ]; then
    clean_dislocker
    echo "dislocker clean ok!"
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
    wget ${AtomLinux_DownloadURL}"tar.gz/v"${AtomLinux_DislockerVNumber} -O ${FILENAME}
    if [ ! $? -eq 0 ]; then
        echo "Error: Download dislocker ."
        exit 1
    fi
    #Check if it is downloaded successfully
    if [ ! -f ./${FILENAME} ]; then
        echo "Error: Download dislocker ."
        exit 1
    fi
fi
#Download Source Code

#Platform
ARCH=x86
if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    ARCH=x86_64
fi
#Platform

clean_dislocker
mkdir ${OBJ_PROJECT}-tmp
tar xzvf ./${FILENAME} -C ./${OBJ_PROJECT}-tmp
#Check Decompression
if [ ! $? -eq 0 ]; then
    echo "Error: Decompression dislocker ."
    exit 1
fi
#Check Decompression

#Code bug processing
RUBYV=`ls /usr/include | grep "^ruby-" | sed -n '1p'`
if [ -f /usr/include/${RUBYV}/ruby/config.h ]; then
    sudo rm -f /usr/include/${RUBYV}/ruby/config.h
fi

if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    sudo ln -s /usr/include/x86_64-linux-gnu/${RUBYV}/ruby/config.h /usr/include/${RUBYV}/ruby/config.h
else
    sudo ln -s /usr/include/i386-linux-gnu/${RUBYV}/ruby/config.h /usr/include/${RUBYV}/ruby/config.h
fi
#Code bug processing

cd ./${OBJ_PROJECT}-tmp/${FILENAME_DIR}

#make
cmake .
#Check cmake
if [ ! $? -eq 0 ]; then
    echo "Error: cmake (dislocker) ."
    exit 1
fi
#Check cmake

if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    echo | $Make dislocker-fuse CXFLAGS=-O2
else
    if [ $(getconf LONG_BIT) = '64' ]; then
        echo | $Make dislocker-fuse CXFLAGS="-O2 -m32"
    else
        echo | $Make dislocker-fuse CXFLAGS=-O2
    fi
fi
#make
#Check make
if [ ! $? -eq 0 ]; then
    echo "Error: make (dislocker) ."
    exit 1
fi
#Check make

#make install
make DESTDIR=../../${ARCH}-${OBJ_PROJECT} install
#make install
#Check make install
if [ ! $? -eq 0 ]; then
    echo "Error: make install (dislocker) ."
    exit 1
fi
#Check make install
rm -rf ../../${ARCH}-${OBJ_PROJECT}/usr/local/share

cd ../../
rm -rf ${OBJ_PROJECT}-tmp

#Code bug processing
if [ -f /usr/include/${RUBYV}/ruby/config.h ]; then
    sudo rm -f /usr/include/${RUBYV}/ruby/config.h
fi
#Code bug processing

echo "Complete."
