#!/bin/sh
apk add --no-cache git python3 py3-pip python3-dev py3-lxml py3-sqlalchemy py3-google-api-python-client py3-pillow apk py3-gevent py3-gevent-websocket py3-yarl py3-aiohttp py3-pycryptodome py3-google-api-python-client ffmpeg

pip3 install flask-login flask-socketio flask-sqlalchemy pytz apscheduler markdown selenium celery redis telepot sqlitedict 
guessit plexapi

cd ~
git clone --depth 1 https://github.com/soju6jan/sjva2_src_obfuscate SJVA2

curl -LO https://raw.githubusercontent.com/soju6jan/sjva_support/master/termux_20201023/alpine_profile2
mv alpine_profile2 /root/.profile
sh /root/.profile

