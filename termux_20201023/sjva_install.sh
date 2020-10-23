#!/bin/bash
curl https://raw.githubusercontent.com/soju6jan/sjva_support/master/termux_20201023/TermuxAlpine_sjva.sh | bash

cd $HOME
echo "1. Download script 1/3"
curl -LO https://raw.githubusercontent.com/soju6jan/sjva_support/master/termux_20201023/alpine_profile1
mv alpine_profile1 /data/data/com.termux/files/usr/share/TermuxAlpine/root/.profile

echo "1. Download script 2/3"
curl -LO https://raw.githubusercontent.com/soju6jan/sjva_support/master/termux_20201023/alpine_install.sh
mv alpine_install.sh /data/data/com.termux/files/usr/share/TermuxAlpine/home/alpine_install.sh

echo "1. Download script 3/3"
cd $HOME
curl -LO https://raw.githubusercontent.com/soju6jan/sjva_support/master/termux_20201023/termux_bash_profile
mv termux_bash_profile ~/.profile


echo "2. Install Alpine.."

startalpine