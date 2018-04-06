# Atom Linux
Atom Linux is a tiny Linux system, which is totally compiled via source code. This script executes automatically and finally generates a complete set of tiny Linux system. Optional graphic development library (Qt\ncurses), specified target platform (x86\amd64).<br>

## Instruction of compiling method<br>
**Required environment: Ubuntu\Debian**<br>
**1. Modify "VeriableSetting" configuration file based on your own needs to change compiling result. This file defines parameters such as source code version, specified target platform, grapgic development library, secure boot support, etc.**<br>
**2. Run "Other\CompilationEnvironment.sh" script to install libraries and common tools required by Atom Linux.**<br>
**3. Run "mk-CompileAll.sh" script to start compiling of entire system.**<br>
**4. Run "test_iso.sh" script to test operating situation of Atom Linux.**<br>

## Other common scripts<br>
**"mk-Clean.sh"** clears compiling result files.<br>
**"BusyBox\CreateCDISO.sh"** creates ISO CD image of Atom Linux.<br>
**"BusyBox\CopyToImgFile.sh"** copies compiling result of Atom Linux to img image file in order to deploy to computer in the future.<br>
**"Other\CompressionVMDK.sh"** If the system is running in VMware virtual machine, you can use this script to compress vmdk virtual disk and free up disk space of host computer.<br>
