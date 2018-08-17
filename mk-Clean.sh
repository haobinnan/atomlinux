#!/usr/bin/env bash

cd LinuxKernel/
./mk-LinuxKernel.sh clean
cd ..

cd Grub2/
./mk-Grub2.sh clean
cd ..

cd Qt/
./mk-Qt4.sh clean
./mk-Qt5.sh clean
cd ..

cd Ncurses/
./mk-ncurses.sh clean
cd ..

cd Lib/glib/
./mk-glib.sh clean
cd ../..

cd Lib/libiconv/
./mk-libiconv.sh clean
cd ../..

cd Utils/mdadm/
./mk-mdadm.sh clean
cd ../..

cd Utils/weston/
./mk-weston.sh clean
cd ../..

cd BusyBox/
./mk-BusyBox.sh clean
cd ..

cd ovmf/
./mk-ovmf.sh clean
cd ..

rm -f ./*.dat *.iso
rm -rf Linux_sample

if [ ! -n "$1" ]; then
    echo "Do you want to clear source code compressed files downloaded during compiling? [y/n]"
    read answer
    if [ $answer = "y" ] || [ $answer = "Y" ]; then
        rm -f ./BusyBox/busybox-*.tar.bz2
        rm -f ./Lib/glib/glib-*.tar.xz
        rm -f ./Lib/libiconv/libiconv-*.tar.gz
        rm -f ./LinuxKernel/linux-*.tar.xz
        rm -f ./Ncurses/ncurses-*.tar.gz
        rm -f ./Qt/qt-everywhere-opensource-src-*.tar.gz
        rm -f ./Qt/qt-everywhere-opensource-src-*.tar.xz
        rm -f ./Utils/mdadm/mdadm-*.tar.xz
        rm -f ./ovmf/*.tar.gz
        rm -f ./Grub2/grub*.tar.*

        #shim
        cd shim/
        ./mk-shim.sh clean
        cd ..
        rm -f ./shim/*.tar.gz
        #shim

        #certificate
        cd certificate/
        rm -f ./*.cer *.crt *.key
        cd ..
        #certificate
    fi
fi

echo "Complete."
