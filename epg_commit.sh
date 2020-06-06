#!/bin/bash
export LANG=en_US.utf8
NowDate=$(date +%Y%m%d)-$(date +%H%M)
APP_HOME=/home/coder/project/SJ/SJVA2
if [ -f "$APP_HOME/data/db/epg.db" ] ; then
    cp $APP_HOME/data/db/epg.db $APP_HOME/data/sjva_support
fi
if [ -f "$APP_HOME/data/output/xmltv_all.xml" ] ; then
    cp $APP_HOME/data/output/xmltv_all.xml $APP_HOME/data/sjva_support
fi
cd $APP_HOME/data/sjva_support && 
git --git-dir $APP_HOME/data/sjva_support/.git add * && 
git --git-dir $APP_HOME/data/sjva_support/.git commit -m $NowDate && 
git --git-dir $APP_HOME/data/sjva_support/.git push

