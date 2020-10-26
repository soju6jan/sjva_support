#!/bin/sh
echo "============================"
echo $@
cd /home
mv /home/alpine_profile2 /root/.profile
apk update
apk add --no-cache git 
apk add --no-cache python3 py3-pip python3-dev py3-lxml py3-sqlalchemy py3-gevent py3-gevent-websocket py3-pycryptodome py3-markupsafe py3-yarl py3-aiohttp py3-wheel py3-markdown
pip3 install flask-login flask-socketio flask-sqlalchemy pytz apscheduler selenium celery redis telepot sqlitedict 
if [ "$1" == "full" ]; then
apk add --no-cache ffmpeg py3-pillow py3-wcwidth py3-google-api-python-client
pip install guessit plexapi
fi
cd /home
git clone --depth 1 https://github.com/soju6jan/sjva2_src_obfuscate /app
mkdir -p /app/bin/LinuxArm
if [ -f "/home/filebrowser" ] ; then
  mv /home/filebrowser /app/bin/LinuxArm
fi
if [ -f "/home/rclone" ] ; then
  mv /home/rclone /app/bin/LinuxArm
fi

cd /app
curl -LO 

echo "Install completed.. Restart Temux.."
#cd SJVA2 && ./start_termux.sh
