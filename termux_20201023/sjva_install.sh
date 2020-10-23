#!/bin/bash
git='https://raw.githubusercontent.com/soju6jan/sjva_support/master/termux_20201023'
alpine='/data/data/com.termux/files/usr/share/TermuxAlpine'

curl -LO $git/TermuxAlpine_sjva.sh &&
bash TermuxAlpine_sjva.sh &&
curl -LO $git/alpine_profile1 &&
mv alpine_profile1 $alpine/root/.profile &&
curl -LO $git/alpine_install.sh &&
mv alpine_install.sh $alpine/home/alpine_install.sh &&
cd $HOME &&
curl -LO $git/termux_bash_profile &&
mv termux_bash_profile ~/.profile &&
startalpine