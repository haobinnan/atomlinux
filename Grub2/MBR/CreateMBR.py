#!/usr/bin/env python
# -*- coding: UTF-8 -*-
#file: CreateMBR.py

import os
import sys
import shutil

def WriteOffset(strFileName, iOffset, strText):
    with open(strFileName, "r+b") as fh:
        fh.seek(iOffset)
        fh.write(strText)
    return

if __name__ == '__main__':
    if len(sys.argv) > 1:
        strAppDir=os.path.dirname(os.path.realpath(__file__))
        strFileName=strAppDir+"/grubmbr"
        strLDRName=sys.argv[1]

        if len(strLDRName) == 5:
            if os.path.exists(strFileName):
                os.remove(strFileName)
            shutil.copyfile(strAppDir + "/grubmbr_", strFileName)

            WriteOffset(strFileName, 0x403, strLDRName.upper())
            WriteOffset(strFileName, 0x5C0, strLDRName.upper())
            WriteOffset(strFileName, 0x603, strLDRName.upper())
            WriteOffset(strFileName, 0x7C3, strLDRName.upper())

            WriteOffset(strFileName, 0x9E3, strLDRName.lower())
            WriteOffset(strFileName, 0xBD3, strLDRName.lower())

            print "MBR file creation completed."
        else:
            print "Error: The parameter is incorrect."
            sys.exit(1)
    else:
        print "Error: The parameter is incorrect."
        sys.exit(1)

