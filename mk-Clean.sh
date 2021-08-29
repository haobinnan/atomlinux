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

cd Utils/dislocker/
./mk-dislocker.sh clean
cd ../..

cd Utils/dropbear/
./mk-dropbear.sh clean
cd ../..

cd Utils/hdparm/
./mk-hdparm.sh clean
cd ../..

cd Utils/exfat/
./mk-exfat.sh clean
cd ../..

cd Utils/ntfs-3g/
./mk-ntfs-3g.sh clean
cd ../..

cd BusyBox/
./mk-BusyBox.sh clean
cd ..

cd ovmf/
./mk-ovmf.sh clean
cd ..

rm -f ./mk-CompileAll_Error.log
rm -f ./*.dat *.iso
rm -rf Linux_sample

if [ ! -n "$1" ]; then
    read -p "Do you want to clear source code compressed files downloaded during compiling? [y/n]" answer
    if [ -z "${answer}" ]; then
        answer="N"
    fi
    if [ $answer = "y" ] || [ $answer = "Y" ]; then
        rm -f ./BusyBox/busybox-*.tar.bz2
        rm -f ./Lib/glib/glib-*.tar.xz
        rm -f ./Lib/libiconv/libiconv-*.tar.gz
        rm -f ./LinuxKernel/linux-*.tar.xz
        rm -f ./Ncurses/ncurses-*.tar.gz
        rm -f ./Qt/qt-everywhere-opensource-src-*.tar.gz
        rm -f ./Qt/qt-everywhere-opensource-src-*.tar.xz
        rm -f ./Utils/mdadm/mdadm-*.tar.xz
        rm -f ./Utils/dislocker/dislocker-*.tar.gz
        rm -f ./Utils/dropbear/dropbear-*.tar.bz2
        rm -f ./Utils/hdparm/hdparm-*.tar.gz
        rm -f ./Utils/exfat/exfat-*.tar.gz
        rm -f ./Utils/ntfs-3g/ntfs-3g_*.tgz
        rm -f ./ovmf/*.tar.gz
        rm -f ./Grub2/grub*.tar.*

        #shim
        cd shim/
        ./mk-shim.sh clean
        cd ..
        rm -f ./shim/*.tar.gz
        rm -f ./shim/*.esl
            #certificate
        rm -f ./shim/certs/*.cer
            #certificate
        #shim
    fi
fi

echo "Complete."
