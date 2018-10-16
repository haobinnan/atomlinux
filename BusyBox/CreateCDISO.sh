#!/usr/bin/env bash

sudo clear

if [ ! -f ../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_GraphicsLibrary="$(grep -i ^AtomLinux_GraphicsLibrary ../VariableSetting | cut -f2 -d'=')"
AtomLinux_InstallationPackageFileName="$(grep -i ^AtomLinux_InstallationPackageFileName ../VariableSetting | cut -f2 -d'=')"
AtomLinux_Grub2PrefixDirName="$(grep -i ^AtomLinux_Grub2PrefixDirName ../VariableSetting | cut -f2 -d'=')"
AtomLinux_Grub2DirName="$(grep -i ^AtomLinux_Grub2DirName ../VariableSetting | cut -f2 -d'=')"
AtomLinux_ISOName="$(grep -i ^AtomLinux_ISOName ../VariableSetting | cut -f2 -d'=')"
AtomLinux_Grub2LdrName="$(grep -i ^AtomLinux_Grub2LdrName ../VariableSetting | cut -f2 -d'=')"
AtomLinux_SoftwareName="$(grep -i ^AtomLinux_SoftwareName ../VariableSetting | cut -f2 -d'=')"
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ../VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

./CopyToImgFile.sh
#Check
if [ ! $? -eq 0 ]; then
    echo "Error: CopyToImgFile.sh ."
    exit 1
fi
#Check

./mk-Bale.sh cd
#Check
if [ ! $? -eq 0 ]; then
    echo "Error: mk-Bale.sh ."
    exit 1
fi
#Check

RAMDISK_NAME=initramfs
rm -f ${AtomLinux_ISOName}
rm -rf iso_tmp
mkdir iso_tmp
cd iso_tmp

# efi
mkdir efi_tmp
cd efi_tmp
cp -rRv ../../../Grub2/efi-i386/* ./
cp -rRv ../../../Grub2/efi-x86_64/* ./
rm -rf .${AtomLinux_Grub2PrefixDirName}/

cd ..
if [ -d ./mnt ]; then
    sudo umount -n ./mnt
fi
initramfsImgSize=$(du -sm ./efi_tmp | awk '{print int($0)}')
dd if=/dev/zero of=./efiboot bs=1M count=${initramfsImgSize}
sudo mkdir ./mnt
sudo mkfs.vfat ./efiboot
sudo mount -t vfat -n ./efiboot ./mnt
sudo cp -rRv ./efi_tmp/* ./mnt/
if [ -d ./mnt ]; then
    sudo umount -n ./mnt
    sudo rm -rf ./mnt
fi

rm -rf ./efi_tmp
# efi

# legacy
cp -rRv ../../Grub2/i386-pc/* ./
rm -f .${AtomLinux_Grub2PrefixDirName}/grub.cfg
rm -f ./${AtomLinux_Grub2LdrName}
cp -v ../../Grub2/cd_grub.cfg .${AtomLinux_Grub2PrefixDirName}/grub.cfg
cp -v ../../Grub2/${AtomLinux_Grub2LdrName}_cd ./
if [ ! -d ./${AtomLinux_Grub2DirName} ]; then
    mkdir ${AtomLinux_Grub2DirName}
fi
if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
    cp -v ../../LinuxKernel/x86/bzImage ./${AtomLinux_Grub2DirName}/bzImage_x86
fi
cp -v ../../LinuxKernel/x86_64/bzImage ./${AtomLinux_Grub2DirName}/bzImage
cp -v ../${RAMDISK_NAME} ./${AtomLinux_Grub2DirName}/
# legacy

# Other
if [ ${AtomLinux_GraphicsLibrary} != "Null" ]; then
    cp -v ../../${AtomLinux_InstallationPackageFileName} ./
fi
# Other

genisoimage -b "${AtomLinux_Grub2LdrName}_cd" -c boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -eltorito-boot efiboot -no-emul-boot -R -J -copyright "${AtomLinux_SoftwareName}" -hide efiboot -hide "${AtomLinux_Grub2LdrName}_cd" -hide boot.cat -hide-joliet efiboot -hide-joliet "${AtomLinux_Grub2LdrName}_cd" -hide-joliet boot.cat -V "${AtomLinux_SoftwareName} Boot" -o "${AtomLinux_ISOName}" .
#Check genisoimage
if [ ! $? -eq 0 ]; then
    echo "Error: genisoimage ."
    exit 1
fi
#Check genisoimage
mv ./${AtomLinux_ISOName} ../../
cd ..
rm -rf iso_tmp

echo "Complete."
