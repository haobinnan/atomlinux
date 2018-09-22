#!/usr/bin/env bash

Make="make -j$(cat /proc/cpuinfo | grep "cpu cores" | wc -l)"

if [ ! -f ../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_DownloadURL="$(grep -i ^AtomLinux_Grub2URL ../VariableSetting | cut -f2 -d'=')"
AtomLinux_Grub2PrefixDirName="$(grep -i ^AtomLinux_Grub2PrefixDirName ../VariableSetting | cut -f2 -d'=')"
AtomLinux_Grub2VNumber="$(grep -i ^AtomLinux_Grub2VNumber ../VariableSetting | cut -f2 -d'=')"
AtomLinux_Grub2LdrName="$(grep -i ^AtomLinux_Grub2LdrName ../VariableSetting | cut -f2 -d'=')"
AtomLinux_UsingPreviousBuildResults_SecureBoot="$(grep -i ^AtomLinux_UsingPreviousBuildResults_SecureBoot ../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

OBJ_PROJECT=grub2
FILENAME_DIR=grub-$AtomLinux_Grub2VNumber
FILENAME=${FILENAME_DIR}.tar.bz2

#Clean
function clean_grub2()
{
    rm -rf ./i386-pc
    rm -rf ./efi-x86_64
    rm -rf ./efi-i386
    rm -f ./*.cfg
    rm -f ./*_cd
    rm -f ./MBR/grubmbr
    rm -rf ./style
    rm -rf ./*.nosign

    rm -rf ${OBJ_PROJECT}-tmp
}

if test $1 && [ $1 = "clean" ]; then
    clean_grub2
    echo "grub2 clean ok!"
    exit
fi
#Clean

#Build Method				[ no: All modules | yes: Single file ]
RemoveModuleCompiledMode=yes

#Code acquisition method		[ git | wget ]
CodeAcquisitionMethod=wget

#Application patches(debian)		[ yes | no ]
ApplicationPatches=no

CurrentDIR=$(pwd)

if [ $CodeAcquisitionMethod = "wget" ]; then
    #Download Source Code
    if [ ! -f ./${FILENAME} ]; then
        #Check if necessary tools are installed
        if [ -z $(which wget) ]; then
            echo "wget is not installed."
            exit 1
        fi
        #Check if necessary tools are installed
        wget ${AtomLinux_DownloadURL}${AtomLinux_Grub2VNumber}/archive.tar.bz2 -O ${FILENAME}
        if [ ! $? -eq 0 ]; then
            echo "Error: Download grub2 ."
            exit 1
        fi
        #Check if it is downloaded successfully
        if [ ! -f ./${FILENAME} ]; then
            echo "Error: Download grub2 ."
            exit 1
        fi
    fi
    #Download Source Code
fi

clean_grub2
mkdir -p ${OBJ_PROJECT}-tmp/install_tmp

if [ $CodeAcquisitionMethod = "wget" ]; then
    tar xjvf ./${FILENAME} -C ./${OBJ_PROJECT}-tmp
    #Check Decompression
    if [ ! $? -eq 0 ]; then
        echo "Error: Decompression grub2 ."
        exit 1
    fi
    #Check Decompression

    #Rename the directory
    mv ./${OBJ_PROJECT}-tmp/grub-debian* ./${OBJ_PROJECT}-tmp/${FILENAME_DIR}
    #Rename the directory
else
    FILENAME_DIR=grub2

    cd ./${OBJ_PROJECT}-tmp/
    git clone --branch ${AtomLinux_Grub2VNumber} ${AtomLinux_DownloadURL}
    cd ..
fi

#Application patches
if [ $ApplicationPatches = "yes" ]; then
    cd ./${OBJ_PROJECT}-tmp/${FILENAME_DIR}

    cat ./debian/patches/series | while read line
    do
        strfile="./debian/patches/${line}"
        echo -e "\033[31m$strfile\033[0m"
        patch -p1 < $strfile
    done

    cd ../../
fi
#Application patches

if [ ! -d ./style ]; then
    mkdir ./style
fi

./CreateCfgFile.sh
#Check
if [ ! $? -eq 0 ]; then
    echo "Error: CreateCfgFile.sh ."
    exit 1
fi
#Check

#i386-pc
LDRNAME=$AtomLinux_Grub2LdrName
ARCH=i386-pc

rm -rf ./${OBJ_PROJECT}-tmp/install_tmp/*

cd ./${OBJ_PROJECT}-tmp/${FILENAME_DIR}
# make distclean
./autogen.sh
#Check autogen
if [ ! $? -eq 0 ]; then
    echo "Error: autogen (Grub2) ."
    exit 1
fi
#Check autogen

# --disable-werror
./configure --with-platform=pc --target=i386 --prefix=${CurrentDIR}/${OBJ_PROJECT}-tmp"/install_tmp" --disable-grub-mount
#Check configure
if [ ! $? -eq 0 ]; then
    echo "Error: configure (Grub2) ."
    exit 1
fi
#Check configure
echo | $Make
#Check make
if [ ! $? -eq 0 ]; then
    echo "Error: make (Grub2) ."
    exit 1
fi
#Check make
make install
#Check make install
if [ ! $? -eq 0 ]; then
    echo "Error: make install (Grub2) ."
    exit 1
fi
#Check make install

cd ../install_tmp/lib/grub/${ARCH}

../../../bin/grub-mkimage --prefix=${AtomLinux_Grub2PrefixDirName} -O i386-pc -d . -o ${LDRNAME}.img biosdisk newc blocklist iso9660 udf memdisk cpio minicmd part_msdos part_gpt msdospart fat ntfs exfat loopback gfxmenu gfxterm reboot normal romfs procfs sleep ls cat echo search configfile halt chain png all_video test linux cpuid scsi
#Check grub-mkimage
if [ ! $? -eq 0 ]; then
    echo "Error: grub-mkimage (Grub2) ."
    exit 1
fi
#Check grub-mkimage

cat lnxboot.img ${LDRNAME}.img > ${LDRNAME}
cat cdboot.img ${LDRNAME}.img > ${LDRNAME}_cd

mv ${LDRNAME} ../../../
mv ${LDRNAME}_cd ../../../

mkdir -p ../../../../../${ARCH}${AtomLinux_Grub2PrefixDirName}/${ARCH}
cp -v *.mod *.lst ../../../../../${ARCH}${AtomLinux_Grub2PrefixDirName}/${ARCH}

cd ../../../../../

cp -v ./font.pf2 ./${ARCH}${AtomLinux_Grub2PrefixDirName}

cp -v ./${OBJ_PROJECT}-tmp/install_tmp/${LDRNAME} ./${ARCH}
cp -v ./${OBJ_PROJECT}-tmp/install_tmp/${LDRNAME}_cd ./

if [ $RemoveModuleCompiledMode = "yes" ]; then
    rm -rf ./${ARCH}${AtomLinux_Grub2PrefixDirName}/${ARCH}
fi
#CreateMBR
MBR/CreateMBR.py ${AtomLinux_Grub2LdrName}
#CreateMBR
#i386-pc

echo "-------------------------------------------------------------"

#function
function build_efi()
{
    LDRNAME=$1
    ARCH=$2

    rm -rf ./${OBJ_PROJECT}-tmp/install_tmp/*

    cd ./${OBJ_PROJECT}-tmp/${FILENAME_DIR}
    make distclean
    ./autogen.sh
    #Check autogen
    if [ ! $? -eq 0 ]; then
        echo "Error: autogen (Grub2) ."
        exit 1
    fi
    #Check autogen

    # --disable-werror
    ./configure --with-platform=efi --target=${ARCH} --prefix=${CurrentDIR}/${OBJ_PROJECT}-tmp"/install_tmp" --disable-grub-mount
    #Check configure
    if [ ! $? -eq 0 ]; then
        echo "Error: configure (Grub2) ."
        exit 1
    fi
    #Check configure
    echo | $Make
    #Check make
    if [ ! $? -eq 0 ]; then
        echo "Error: make (Grub2) ."
        exit 1
    fi
    #Check make
    make install
    #Check make install
    if [ ! $? -eq 0 ]; then
        echo "Error: make install (Grub2) ."
        exit 1
    fi
    #Check make install

    cd ../install_tmp/lib/grub/${ARCH}-efi

    #All mod
    # $(ls *.mod | cut -d '.' -f 1)
    #All mod

    ../../../bin/grub-mkimage -O ${ARCH}-efi -d . -o ${LDRNAME} -p ${AtomLinux_Grub2PrefixDirName} newc memdisk cpio part_gpt part_msdos msdospart ntfs ntfscomp fat exfat normal chain boot configfile linux multiboot png all_video search blocklist iso9660 udf minicmd loopback gfxmenu gfxterm reboot romfs procfs sleep ls cat echo halt test linux cpuid scsi linuxefi lsefi lsefimmap efifwsetup efinet backtrace font loadenv syslinuxcfg video
    #Check grub-mkimage
    if [ ! $? -eq 0 ]; then
        echo "Error: grub-mkimage (Grub2) ."
        exit 1
    fi
    #Check grub-mkimage

    mv ${LDRNAME} ../../../

    mkdir -p ../../../../../efi-${ARCH}${AtomLinux_Grub2PrefixDirName}/${ARCH}-efi
    cp -v *.mod *.lst ../../../../../efi-${ARCH}${AtomLinux_Grub2PrefixDirName}/${ARCH}-efi

    cd ../../../../../

    cp -v ./font.pf2 ./efi-${ARCH}${AtomLinux_Grub2PrefixDirName}

    mkdir -p ./efi-${ARCH}/EFI/BOOT
    cp -v ./${OBJ_PROJECT}-tmp/install_tmp/${LDRNAME} ./efi-${ARCH}/EFI/BOOT

    if [ $RemoveModuleCompiledMode = "yes" ]; then
        rm -rf ./efi-${ARCH}${AtomLinux_Grub2PrefixDirName}/${ARCH}-efi
    fi
}

function build_efi_SecureBoot()
{
    ARCH=$1

    mkdir ./efi-${ARCH}
    cp -rv ./SecureBoot/${ARCH}/* ./efi-${ARCH}/

    if [ $RemoveModuleCompiledMode = "yes" ]; then
        if [ -d ./efi-${ARCH}${AtomLinux_Grub2PrefixDirName}/${ARCH}-efi ]; then
            rm -rf ./efi-${ARCH}${AtomLinux_Grub2PrefixDirName}/${ARCH}-efi
        fi
    fi
}
#function

#i386-efi
if [ $AtomLinux_UsingPreviousBuildResults_SecureBoot = "Yes" ]; then
    build_efi_SecureBoot i386
else
    build_efi bootia32.efi i386
fi
#i386-efi

echo "-------------------------------------------------------------"

#x86_64-efi
if [ $AtomLinux_UsingPreviousBuildResults_SecureBoot = "Yes" ]; then
    build_efi_SecureBoot x86_64
else
    build_efi bootx64.efi x86_64
fi
#x86_64-efi

rm -rf ${OBJ_PROJECT}-tmp

echo "Complete."
