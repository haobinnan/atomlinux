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

AtomLinux_key="$(grep -i ^AtomLinux_key ./VariableSetting | cut -f2 -d'=')"
AtomLinux_crt="$(grep -i ^AtomLinux_crt ./VariableSetting | cut -f2 -d'=')"
#Load from VariableSetting file

if [ ${AtomLinux_SecureBootSignature} = "Yes" ]; then
    if [ ${AtomLinux_SignatureMethod} = "CodeSgin" ]; then
        if [ ! -f ./certificate/$AtomLinux_key ]; then
            echo "Error: key file does not exist ."
            exit 1
        fi

        if [ ! -f ./certificate/$AtomLinux_crt ]; then
            echo "Error: crt file does not exist ."
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
cd LinuxKernel
./mk-LinuxKernel.sh
#Check
if [ ! $? -eq 0 ]; then
    echo "Error: mk-LinuxKernel.sh ."
    exit 1
fi
#Check
#SecureBoot Signature
if [ ${AtomLinux_SecureBootSignature} = "Yes" ]; then
    ./mk-KernelSignature.sh
    #Check
    if [ ! $? -eq 0 ]; then
        echo "Error: mk-KernelSignature.sh ."
        exit 1
    fi
    #Check
fi
#SecureBoot Signature
cd ..
# ********************************** LinuxKernel **********************************

# ********************************** GraphicsLibrary **********************************
if [ ${AtomLinux_GraphicsLibrary} = "Qt" ]; then
    cd Qt
    ./mk-Qt4.sh
    #Check
    if [ ! $? -eq 0 ]; then
        echo "Error: mk-Qt4.sh ."
        exit 1
    fi
    #Check
    cd ..
elif [ ${AtomLinux_GraphicsLibrary} = "Qt5" ]; then
    cd Qt
    ./mk-Qt5.sh
    #Check
    if [ ! $? -eq 0 ]; then
        echo "Error: mk-Qt5.sh ."
        exit 1
    fi
    #Check
    cd ..
elif [ ${AtomLinux_GraphicsLibrary} = "Ncurses" ]; then
    cd Ncurses
    ./mk-ncurses.sh
    #Check
    if [ ! $? -eq 0 ]; then
        echo "Error: mk-ncurses.sh ."
        exit 1
    fi
    #Check
    cd ..
fi
# ********************************** GraphicsLibrary **********************************

# ********************************** Grub2 **********************************
cd Grub2
./mk-Grub2.sh
#Check
if [ ! $? -eq 0 ]; then
    echo "Error: mk-Grub2.sh ."
    exit 1
fi
#Check
#SecureBoot Signature
if [ ${AtomLinux_SecureBootSignature} = "Yes" ]; then
    ./mk-Grub2Signature.sh
    #Check
    if [ ! $? -eq 0 ]; then
        echo "Error: mk-Grub2Signature.sh ."
        exit 1
    fi
    #Check
fi
#SecureBoot Signature
cd ..
# ********************************** Grub2 **********************************

# ********************************** libiconv **********************************
cd Lib/libiconv
./mk-libiconv.sh
#Check
if [ ! $? -eq 0 ]; then
    echo "Error: mk-libiconv.sh ."
    exit 1
fi
#Check
cd ../../
# ********************************** libiconv **********************************

# ********************************** mdadm **********************************
cd Utils/mdadm
./mk-mdadm.sh
#Check
if [ ! $? -eq 0 ]; then
    echo "Error: mk-mdadm.sh ."
    exit 1
fi
#Check
cd ../../
# ********************************** mdadm **********************************

# ********************************** BusyBox **********************************
cd BusyBox
./mk-BusyBox.sh
#Check
if [ ! $? -eq 0 ]; then
    echo "Error: mk-BusyBox.sh ."
    exit 1
fi
#Check
cd ..
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
