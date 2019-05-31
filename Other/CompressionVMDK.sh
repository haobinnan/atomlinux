#!/usr/bin/env bash

sudo clear

#ubuntu use
echo y | sudo apt autoremove
echo y | sudo apt autoclean
echo y | sudo apt clean
#ubuntu use

rm -rf ~/.cache/vmware/drag_and_drop/*

#Compress vmdk
sudo vmware-toolbox-cmd disk shrink /

echo "Complete."
