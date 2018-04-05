Atom Linux is a tiny Linux system, which is totally compiled via source code. This script executes automatically and finally generates a complete set of tiny Linux system. Optional graphic development library (QT\ncurses), specified target platform (x86\amd64)

Instruction of compiling method:
Required environment: Ubuntu\Debian
1. Modify "VeriableSetting" configuration file based on your own needs to change compiling result. This file defines parameters such as source code version, specified target platform, grapgic development library, secure boot support, etc.
2. Run "Other\CompilationEnvironment.sh" script to install libraries and common tools required by Atom Linux.
3. Run "mk-CompileAll.sh" script to start compiling of entire system.
4. Run "test_iso.sh" script to test operating situation of Atom Linux.

Other common scripts:
"mk-Clean.sh" clears compiling result files.
"BusyBox\CreateCDISO.sh"creates ISO CD image of Atom Linux.
"BusyBox\CopyToImgFile.sh" copies compiling result of Atom Linux to img image file in order to deploy to computer in the future.
"Other\CompressionVMDK.sh" If the system is running in VMware virtual machine, you can use this script to compress vmdk virtual disk and free up disk space of host computer.

Directory:
.
├── BusyBox
│   ├── CopyLib.sh
│   ├── CopyToImgFile.sh
│   ├── CreateCDISO.sh
│   ├── mk-Bale.sh
│   ├── mk-BusyBox.sh
│   └── MyConfig
│       └── etc
│           ├── fstab
│           ├── group
│           ├── hostname
│           ├── init.d
│           │   └── rcS
│           ├── inittab
│           ├── passwd
│           └── profile
├── certificate
│   └── readme.txt
├── Grub2
│   ├── CreateCfgFile.sh
│   ├── font.pf2
│   ├── MBR
│   │   └── grubmbr
│   ├── mk-Grub2.sh
│   ├── mk-Grub2Signature.sh
│   └── SecureBoot
│       └── shim
│           └── readme.txt
├── Lib
│   ├── glib
│   │   └── mk-glib.sh
│   └── libiconv
│       └── mk-libiconv.sh
├── LinuxKernel
│   ├── mk-KernelSignature.sh
│   └── mk-LinuxKernel.sh
├── mk-Clean.sh
├── mk-CompileAll.sh
├── mk-LinuxSample.sh
├── Ncurses
│   └── mk-ncurses.sh
├── Other
│   ├── CompilationEnvironment.sh
│   └── CompressionVMDK.sh
├── Qt
│   ├── mk-Qt4.sh
│   └── mk-Qt5.sh
├── shim
│   └── mk-shim.sh
├── test_iso.sh
├── Utils
│   └── mdadm
│       └── mk-mdadm.sh
└── VariableSetting

