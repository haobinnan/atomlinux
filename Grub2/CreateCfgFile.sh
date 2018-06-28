#!/usr/bin/env bash

if [ ! -f ../VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_Grub2DirName="$(grep -i ^AtomLinux_Grub2DirName ../VariableSetting | cut -f2 -d'=')"
AtomLinux_Grub2StyleDirName="$(grep -i ^AtomLinux_Grub2StyleDirName ../VariableSetting | cut -f2 -d'=')"
AtomLinux_SoftwareName="$(grep -i ^AtomLinux_SoftwareName ../VariableSetting | cut -f2 -d'=')"
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ../VariableSetting | cut -f2 -d'=')"
AtomLinux_LinuxKernelParameter="$(grep -i ^AtomLinux_LinuxKernelParameter ../VariableSetting | sed s/AtomLinux_LinuxKernelParameter=// | sed s/\"//g)"
#Load from VariableSetting file

NotCreated_Main_GrubCfg=yes

#Create grub.cfg file
if [ ${NotCreated_Main_GrubCfg} != "yes" ]; then
    if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
        echo "insmod part_gpt
insmod part_msdos
insmod png
insmod all_video
insmod gfxterm

loadfont \$prefix/font.pf2

set timeout=0
set default=0
set gfxmode=1024x768
set gfxpayload=keep

terminal_output gfxterm
search --no-floppy --file --set=root /$AtomLinux_Grub2DirName/$AtomLinux_Grub2StyleDirName/style.txt
set theme=/$AtomLinux_Grub2DirName/$AtomLinux_Grub2StyleDirName/style.txt

menuentry ' ' --hotkey=f0 {
    linux /$AtomLinux_Grub2DirName/bzImage$AtomLinux_LinuxKernelParameter
    initrd /$AtomLinux_Grub2DirName/initramfs
}" > ./grub.cfg
    else
        echo "insmod part_gpt
insmod part_msdos
insmod png
insmod all_video
insmod gfxterm

loadfont \$prefix/font.pf2

set timeout=0
set default=0
set gfxmode=1024x768
set gfxpayload=keep
terminal_output gfxterm

search --no-floppy --file --set=root /$AtomLinux_Grub2DirName/$AtomLinux_Grub2StyleDirName/style.txt
set theme=/$AtomLinux_Grub2DirName/$AtomLinux_Grub2StyleDirName/style.txt

menuentry ' ' --hotkey=f0 {
    if cpuid -l; then
        linux /$AtomLinux_Grub2DirName/bzImage$AtomLinux_LinuxKernelParameter
    else
        linux /$AtomLinux_Grub2DirName/bzImage_x86$AtomLinux_LinuxKernelParameter
    fi
    initrd /$AtomLinux_Grub2DirName/initramfs
}" > ./grub.cfg
    fi
fi
#Create grub.cfg file

#Create grub.cfg file for CD
if [ ${AtomLinux_Only64Bit} = "Yes" ]; then
    echo "insmod part_gpt
insmod part_msdos
insmod png
insmod all_video
insmod gfxterm

loadfont \$prefix/font.pf2

set timeout=0
set default=0
set gfxpayload=1024x768

menuentry '$AtomLinux_SoftwareName' {
    echo 'Loading ...'
    linux /$AtomLinux_Grub2DirName/bzImage$AtomLinux_LinuxKernelParameter
    initrd /$AtomLinux_Grub2DirName/initramfs
}" > ./cd_grub.cfg
else
    echo "insmod part_gpt
insmod part_msdos
insmod png
insmod all_video
insmod gfxterm

loadfont \$prefix/font.pf2

set timeout=0
set default=0
set gfxpayload=1024x768

menuentry '$AtomLinux_SoftwareName' {
    echo 'Loading ...'
    if cpuid -l; then
        linux /$AtomLinux_Grub2DirName/bzImage$AtomLinux_LinuxKernelParameter
    else
        linux /$AtomLinux_Grub2DirName/bzImage_x86$AtomLinux_LinuxKernelParameter
    fi
    initrd /$AtomLinux_Grub2DirName/initramfs
}" > ./cd_grub.cfg
fi
#Create grub.cfg file for CD

echo "Complete."
