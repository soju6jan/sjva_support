#!/bin/sh
cd /home
mv /home/alpine_profile2 /root/.profile
apk update
apk add --no-cache git 
apk add --no-cache python3 py3-pip python3-dev py3-lxml py3-sqlalchemy py3-gevent py3-gevent-websocket py3-pycryptodome py3-markupsafe 
# ffmpeg py3-pillow py3-yarl py3-aiohttp py3-wcwidth py3-google-api-python-client
pip3 install flask-login flask-socketio flask-sqlalchemy pytz apscheduler markdown selenium celery redis telepot sqlitedict 
#pip install guessit plexapi

cd /home
git clone --depth 1 https://github.com/soju6jan/sjva2_src_obfuscate SJVA2
mkdir -p /home/SJVA2/bin/LinuxArm
mv /home/filebrowser /home/SJVA2/bin/LinuxArm
mv /home/rclone /home/SJVA2/bin/LinuxArm
cd SJVA2 && ./start_termux.sh
