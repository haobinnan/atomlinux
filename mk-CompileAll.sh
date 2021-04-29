#!/usr/bin/env bash

sudo clear

if [ ! -f ./VariableSetting ]; then
    echo "Error: VariableSetting file does not exist ."
    exit 1
fi

#Load from VariableSetting file
AtomLinux_Only64Bit="$(grep -i ^AtomLinux_Only64Bit ./VariableSetting | cut -f2 -d'=')"
AtomLinux_GraphicsLibrary="$(grep -i ^AtomLinux_GraphicsLibrary ./VariableSetting | cut -f2 -d'=')"
AtomLinux_SecureBootSignature="$(grep -i ^AtomLinux_SecureBootSignature ./VariableSetting | cut -f2 -d'=')"
AtomLinux_SignatureMethod="$(grep -i ^AtomLinux_SignatureMethod ./VariableSetting | cut -f2 -d'=')"
AtomLinux_UsingPreviousBuildResults_SecureBoot="$(grep -i ^AtomLinux_UsingPreviousBuildResults_SecureBoot ./VariableSetting | cut -f2 -d'=')"
AtomLinux_UsingIconvLib="$(grep -i ^AtomLinux_UsingIconvLib ./VariableSetting | cut -f2 -d'=')"
AtomLinux_UsingGlibLib="$(grep -i ^AtomLinux_UsingGlibLib ./VariableSetting | cut -f2 -d'=')"
AtomLinux_UsingMdadm="$(grep -i ^AtomLinux_UsingMdadm ./VariableSetting | cut -f2 -d'=')"
AtomLinux_UsingDislocker="$(grep -i ^AtomLinux_UsingDislocker ./VariableSetting | cut -f2 -d'=')"
AtomLinux_UsingDropbearSSH="$(grep -i ^AtomLinux_UsingDropbearSSH ./VariableSetting | cut -f2 -d'=')"
AtomLinux_UsingHdparm="$(grep -i ^AtomLinux_UsingHdparm ./VariableSetting | cut -f2 -d'=')"
AtomLinux_UsingExfat="$(grep -i ^AtomLinux_UsingExfat ./VariableSetting | cut -f2 -d'=')"
AtomLinux_UsingNtfs3g="$(grep -i ^AtomLinux_UsingNtfs3g ./VariableSetting | cut -f2 -d'=')"
AtomLinux_UsingWeston="$(grep -i ^AtomLinux_UsingWeston ./VariableSetting | cut -f2 -d'=')"

AtomLinux_CertificatePath="$(grep -i ^AtomLinux_CertificatePath ./VariableSetting | cut -f2 -d'=')"
AtomLinux_CertificateName="$(grep -i ^AtomLinux_CertificateName ./VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

if [ ${AtomLinux_SecureBootSignature} = "Yes" ]; then
    if [ ${AtomLinux_SignatureMethod} = "CodeSgin" ]; then
        certutil -L -d $AtomLinux_CertificatePath -n "$AtomLinux_CertificateName" > /dev/null
        if [ ! $? -eq 0 ]; then
            echo "Error: Secure boot signature certificate does not exist."
            exit 1
        fi
    fi

    if [ ! -f ./Grub2/SecureBoot/shim/shimia32.efi ]; then
        echo "Error: shimia32.efi file does not exist ."
        exit 1
    fi

    if [ ! -f ./Grub2/SecureBoot/shim/shimx64.efi ]; then
        echo "Error: shimx64.efi file does not exist ."
        exit 1
    fi
fi

if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
    echo -e "****************** \033[31mTarget platform\033[0m:{\033[33m32-bit\033[0m} ******************"
else
    echo -e "****************** \033[31mTarget platform\033[0m:{\033[33m64-bit\033[0m} ******************"
fi
echo -e "****************** \033[31mGraphicsLibrary\033[0m:{\033[33m"${AtomLinux_GraphicsLibrary}"\033[0m} ******************"
echo -e "****************** \033[31mEnabled SecureBootSignature\033[0m:{\033[33m"${AtomLinux_SecureBootSignature}"\033[0m} ******************"
if [ ${AtomLinux_SecureBootSignature} = "Yes" ]; then
    echo -e "****************** \033[31mSignature Method\033[0m:{\033[33m"${AtomLinux_SignatureMethod}"\033[0m} ******************"
fi

echo "Proceed anyway? [y/n]"
read answer
if [ $answer = "n" ] || [ $answer = "N" ]; then
    exit 1
fi

#Check if necessary tools are installed
if [ -z $(which wget) ]; then
    echo "wget is not installed."
    exit 1
fi
#Check if necessary tools are installed

./mk-Clean.sh transfer

strStartTime=`date "+%Y-%m-%d %H:%M:%S"`

# ********************************** LinuxKernel **********************************
function Build_LinuxKernel()
{
    cd LinuxKernel
    ./mk-LinuxKernel.sh
    #Check
    if [ ! $? -eq 0 ]; then
        echo "Error: mk-LinuxKernel.sh ." >> ../mk-CompileAll_Error.log
        exit 1
    fi
    #Check
    #SecureBoot Signature
    if [ ${AtomLinux_SecureBootSignature} = "Yes" ]; then
        ./mk-KernelSignature.sh
        #Check
        if [ ! $? -eq 0 ]; then
            echo "Error: mk-KernelSignature.sh ." >> ../mk-CompileAll_Error.log
            exit 1
        fi
        #Check
    fi
    #SecureBoot Signature
    cd ..
}
Build_LinuxKernel &
# ********************************** LinuxKernel **********************************

# ********************************** Grub2 **********************************
function Build_Grub2()
{
    cd Grub2
    ./mk-Grub2.sh
    #Check
    if [ ! $? -eq 0 ]; then
        echo "Error: mk-Grub2.sh ." >> ../mk-CompileAll_Error.log
        exit 1
    fi
    #Check
    #SecureBoot Signature
    if [ ${AtomLinux_SecureBootSignature} = "Yes" ] && [ ${AtomLinux_UsingPreviousBuildResults_SecureBoot} != "Yes" ]; then
        ./mk-Grub2Signature.sh
        #Check
        if [ ! $? -eq 0 ]; then
            echo "Error: mk-Grub2Signature.sh ." >> ../mk-CompileAll_Error.log
            exit 1
        fi
        #Check
    fi
    #SecureBoot Signature
    cd ..
}
Build_Grub2 &
# ********************************** Grub2 **********************************

# ********************************** GraphicsLibrary **********************************
function Build_GraphicsLibrary()
{
    if [ ${AtomLinux_GraphicsLibrary} = "Qt" ]; then
        cd Qt
        ./mk-Qt4.sh
        #Check
        if [ ! $? -eq 0 ]; then
            echo "Error: mk-Qt4.sh ." >> ../mk-CompileAll_Error.log
            exit 1
        fi
        #Check
        cd ..
    elif [ ${AtomLinux_GraphicsLibrary} = "Qt5" ]; then
        cd Qt
        ./mk-Qt5.sh
        #Check
        if [ ! $? -eq 0 ]; then
            echo "Error: mk-Qt5.sh ." >> ../mk-CompileAll_Error.log
            exit 1
        fi
        #Check
        cd ..
    elif [ ${AtomLinux_GraphicsLibrary} = "Ncurses" ]; then
        cd Ncurses
        ./mk-ncurses.sh
        #Check
        if [ ! $? -eq 0 ]; then
            echo "Error: mk-ncurses.sh ." >> ../mk-CompileAll_Error.log
            exit 1
        fi
        #Check
        cd ..
    fi
}
Build_GraphicsLibrary &
# ********************************** GraphicsLibrary **********************************

# ********************************** libiconv **********************************
function Build_libiconv()
{
    if [ ${AtomLinux_UsingIconvLib} = "Yes" ]; then
        cd Lib/libiconv
        ./mk-libiconv.sh
        #Check
        if [ ! $? -eq 0 ]; then
            echo "Error: mk-libiconv.sh ." >> ../../mk-CompileAll_Error.log
            exit 1
        fi
        #Check
        cd ../../
    fi
}
Build_libiconv &
# ********************************** libiconv **********************************

# ********************************** libGlib **********************************
function Build_libGlib()
{
    if [ ${AtomLinux_UsingGlibLib} = "Yes" ]; then
        cd Lib/glib
        ./mk-glib.sh
        #Check
        if [ ! $? -eq 0 ]; then
            echo "Error: mk-glib.sh ." >> ../../mk-CompileAll_Error.log
            exit 1
        fi
        #Check
        cd ../../
    fi
}
Build_libGlib &
# ********************************** libGlib **********************************

# ********************************** mdadm **********************************
function Build_mdadm()
{
    if [ ${AtomLinux_UsingMdadm} = "Yes" ]; then
        cd Utils/mdadm
        ./mk-mdadm.sh
        #Check
        if [ ! $? -eq 0 ]; then
            echo "Error: mk-mdadm.sh ." >> ../../mk-CompileAll_Error.log
            exit 1
        fi
        #Check
        cd ../../
    fi
}
Build_mdadm &
# ********************************** mdadm **********************************

# ********************************** dislocker **********************************
function Build_dislocker()
{
    if [ ${AtomLinux_UsingDislocker} = "Yes" ]; then
        cd Utils/dislocker
        ./mk-dislocker.sh
        #Check
        if [ ! $? -eq 0 ]; then
            echo "Error: mk-dislocker.sh ." >> ../../mk-CompileAll_Error.log
            exit 1
        fi
        #Check
        cd ../../
    fi
}
Build_dislocker &
# ********************************** dislocker **********************************

# ********************************** Dropbear SSH **********************************
function Build_DropbearSSH()
{
    if [ ${AtomLinux_UsingDropbearSSH} = "Yes" ]; then
        cd Utils/dropbear
        ./mk-dropbear.sh
        #Check
        if [ ! $? -eq 0 ]; then
            echo "Error: mk-dropbear.sh ." >> ../../mk-CompileAll_Error.log
            exit 1
        fi
        #Check
        cd ../../
    fi
}
Build_DropbearSSH &
# ********************************** Dropbear SSH **********************************

# ********************************** hdparm **********************************
function Build_hdparm()
{
    if [ ${AtomLinux_UsingHdparm} = "Yes" ]; then
        cd Utils/hdparm
        ./mk-hdparm.sh
        #Check
        if [ ! $? -eq 0 ]; then
            echo "Error: mk-hdparm.sh ." >> ../../mk-CompileAll_Error.log
            exit 1
        fi
        #Check
        cd ../../
    fi
}
Build_hdparm &
# ********************************** hdparm **********************************

# ********************************** exfat **********************************
function Build_exfat()
{
    if [ ${AtomLinux_UsingExfat} = "Yes" ]; then
        cd Utils/exfat
        ./mk-exfat.sh
        #Check
        if [ ! $? -eq 0 ]; then
            echo "Error: mk-exfat.sh ." >> ../../mk-CompileAll_Error.log
            exit 1
        fi
        #Check
        cd ../../
    fi
}
Build_exfat &
# ********************************** exfat **********************************

# ********************************** ntfs-3g **********************************
function Build_Ntfs3g()
{
    if [ ${AtomLinux_UsingNtfs3g} = "Yes" ]; then
        cd Utils/ntfs-3g
        ./mk-ntfs-3g.sh
        #Check
        if [ ! $? -eq 0 ]; then
            echo "Error: mk-ntfs-3g.sh ." >> ../../mk-CompileAll_Error.log
            exit 1
        fi
        #Check
        cd ../../
    fi
}
Build_Ntfs3g &
# ********************************** ntfs-3g **********************************

# ********************************** weston **********************************
function Build_weston()
{
    if [ ${AtomLinux_UsingWeston} = "Yes" ]; then
        cd Utils/weston
        ./mk-weston.sh
        #Check
        if [ ! $? -eq 0 ]; then
            echo "Error: mk-weston.sh ." >> ../../mk-CompileAll_Error.log
            exit 1
        fi
        #Check
        cd ../../
    fi
}
Build_weston &
# ********************************** weston **********************************

# ********************************** ovmf **********************************
function Build_ovmf()
{
    cd ovmf
    ./mk-ovmf.sh
    #Check
    if [ ! $? -eq 0 ]; then
        echo "Error: mk-ovmf.sh ." >> ../mk-CompileAll_Error.log
        exit 1
    fi
    #Check

    gnome-terminal --tab --title="QEMU - Import Secure Boot Keys" -- ./ImportSecureBootKeys.sh

    cd ../
}
Build_ovmf &
# ********************************** ovmf **********************************

# ********************************** BusyBox **********************************
function Build_BusyBox()
{
    cd BusyBox
    ./mk-BusyBox.sh
    #Check
    if [ ! $? -eq 0 ]; then
        echo "Error: mk-BusyBox.sh ." >> ../mk-CompileAll_Error.log
        exit 1
    fi
    #Check
    cd ..
}
Build_BusyBox &
# ********************************** BusyBox **********************************

#SecureBootSignature
if [ ${AtomLinux_SecureBootSignature} = "Yes" ]; then
    if [ ${AtomLinux_SignatureMethod} = "EVCodeSgin" ]; then
        if [ ${AtomLinux_Only64Bit} != "Yes" ]; then
            echo -e "****************** \033[31mPlease sign file\033[0m:\033[33m$(pwd)/LinuxKernel/x86/bzImage\033[0m ******************"
        fi
        echo -e "****************** \033[31mPlease sign file\033[0m:\033[33m$(pwd)/LinuxKernel/x86_64/bzImage\033[0m ******************"
        echo -e "****************** \033[31mPlease sign file\033[0m:\033[33m$(pwd)/Grub2/efi-i386/EFI/BOOT/grubia32.efi\033[0m ******************"
        echo -e "****************** \033[31mPlease sign file\033[0m:\033[33m$(pwd)/Grub2/efi-x86_64/EFI/BOOT/grubx64.efi\033[0m ******************"

        echo "Press Enter to continue after signing completes."
        read answer
    fi
fi
#SecureBootSignature

wait

if [ -f ./mk-CompileAll_Error.log ]; then
    echo "Error exists in the compilation process ."
    exit 1
fi

./mk-LinuxSample.sh
if [ ${AtomLinux_GraphicsLibrary} = "Null" ]; then
    cd BusyBox
    ./CreateCDISO.sh
    #Check
    if [ ! $? -eq 0 ]; then
        echo "Error: CreateCDISO.sh ."
        exit 1
    fi
    #Check
    cd ..
fi

strEndTime=`date "+%Y-%m-%d %H:%M:%S"`
echo Start time: ${strStartTime}
echo Ending time: ${strEndTime}
StartTime=`date -d "${strStartTime}" +%s`
strEndTime=`date -d "${strEndTime}" +%s`
timediff=$(( ${strEndTime} - ${StartTime} ))
#days=$(( ${timediff} / 86400 ))
remain=$(( ${timediff} % 86400 ))
hours=$(( ${remain} / 3600 ))
remain=$(( ${remain} % 3600 ))
mins=$(( ${remain} / 60 ))
secs=$(( ${remain} % 60 ))
echo Elapsed time: ${hours}hours ${mins}minutes ${secs}seconds

echo "Complete."
