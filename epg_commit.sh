#!/bin/bash
export LANG=en_US.utf8
NowDate=$(date +%Y%m%d)-$(date +%H%M)
APP_HOME=/home/coder/project/SJ/SJVA2
cp $APP_HOME/etc/epg.db $APP_HOME/data/sjva_support
cd $APP_HOME/data/sjva_support && 
git --git-dir $APP_HOME/data/sjva_support/.git add * && 
git --git-dir $APP_HOME/data/sjva_support/.git commit -m $NowDate && 
git --git-dir $APP_HOME/data/sjva_support/.git push

