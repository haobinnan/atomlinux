#!/usr/bin/env bash

if [ ! -f ./VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_Grub2DirName="$(grep -i ^AtomLinux_Grub2DirName ./VariableSetting | cut -f2 -d'=')"
AtomLinux_Grub2StyleDirName="$(grep -i ^AtomLinux_Grub2StyleDirName ./VariableSetting | cut -f2 -d'=')"
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ./VariableSetting | cut -f2 -d'=')"
AtomLinux_BCDDeploymentMethod="$(grep -i ^AtomLinux_BCDDeploymentMethod ./VariableSetting | cut -f2 -d'=')"
AtomLinux_SoftwareName="$(grep -i ^AtomLinux_SoftwareName ./VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

rm -rf ./Linux_sample

mkdir -p Linux_sample/LegacyBIOSBoot/
mkdir -p Linux_sample/EFIBIOSBoot/32Bit/
mkdir -p Linux_sample/EFIBIOSBoot/64Bit/

if [ ${AtomLinux_BCDDeploymentMethod} = "Yes" ]; then
    cp -rv ./Grub2/font.pf2 ./Linux_sample/

    cp -rv ./Grub2/i386-pc/* ./Linux_sample/LegacyBIOSBoot/
    cp -rv ./Grub2/efi-i386/EFI/BOOT/* ./Linux_sample/EFIBIOSBoot/32Bit/
    cp -rv ./Grub2/efi-x86_64/EFI/BOOT/* ./Linux_sample/EFIBIOSBoot/64Bit/

    rm -rf ./Linux_sample/LegacyBIOSBoot/${AtomLinux_Grub2DirName}

    mv ./Linux_sample/EFIBIOSBoot/32Bit/bootia32.efi ./Linux_sample/EFIBIOSBoot/32Bit/${AtomLinux_SoftwareName}_boot.efi
    mv ./Linux_sample/EFIBIOSBoot/64Bit/bootx64.efi ./Linux_sample/EFIBIOSBoot/64Bit/${AtomLinux_SoftwareName}_boot.efi
else
    cp -rv ./Grub2/i386-pc/* ./Linux_sample/LegacyBIOSBoot/
    cp -rv ./Grub2/efi-i386/* ./Linux_sample/EFIBIOSBoot/32Bit/
    cp -rv ./Grub2/efi-x86_64/* ./Linux_sample/EFIBIOSBoot/64Bit/
fi

if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
    mkdir -p Linux_sample/Kernel/32Bit/
    cp -rv ./LinuxKernel/x86/* ./Linux_sample/Kernel/32Bit/
fi
mkdir -p Linux_sample/Kernel/64Bit/
cp -rv ./LinuxKernel/x86_64/* ./Linux_sample/Kernel/64Bit/

if [ ${AtomLinux_BCDDeploymentMethod} = "No" ]; then
    if [ $(ls ./Grub2/style/ -A $1|wc -w | awk '{print int($0)}') -gt 0 ]; then
        mkdir -p Linux_sample/${AtomLinux_Grub2DirName}/${AtomLinux_Grub2StyleDirName}/
        cp -rv ./Grub2/style/* ./Linux_sample/${AtomLinux_Grub2DirName}/${AtomLinux_Grub2StyleDirName}/
    fi
fi

cp -rv ./Grub2/MBR/grubmbr ./Linux_sample/

echo "Complete."
