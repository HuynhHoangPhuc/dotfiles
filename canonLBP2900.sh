#!/bin/bash


sudo apt -y install build-essential git autoconf libtool libcups2-dev libcupsimage2-dev ttf-mscorefonts-installer
sudo fc-cache -f -v
git clone https://github.com/agalakhov/captdriver.git
cd captdriver
autoreconf -i
./configure
make
sudo cp src/rastertocapt /usr/lib/cups/filter/
sudo cp Canon-LBP2900.ppd /usr/share/ppd/custom/
