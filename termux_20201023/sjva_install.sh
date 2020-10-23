#!/bin/bash
git='https://raw.githubusercontent.com/soju6jan/sjva_support/master/termux_20201023'
git2='https://raw.githubusercontent.com/soju6jan/SJVA2/master/bin/LinuxArm'
alpine='/data/data/com.termux/files/usr/share/TermuxAlpine'
curl -LO $git/TermuxAlpine_sjva.sh
bash TermuxAlpine_sjva.sh
curl -LO $git/alpine_profile1
sed -i "s/args/$@/" alpine_profile1
cat alpine_profile1
mv alpine_profile1 $alpine/root/.profile
curl -LO $git/alpine_profile2
mv alpine_profile2 $alpine/home
curl -LO $git/alpine_install.sh
mv alpine_install.sh $alpine/home/alpine_install.sh
if [ $1 == "full" ]; then
curl -LO $git2/filebrowser
mv filebrowser $alpine/home
curl -LO $git2/rclone
mv rclone $alpine/home
fi
cd $HOME
curl -LO $git/termux_bash_profile
mv termux_bash_profile ~/.profile
startalpine