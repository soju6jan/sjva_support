#!/bin/bash
#if [ $0 != /usr/bin/si ]; then
#    mv -f $0 /usr/bin/si
#    chmod +x /usr/bin/si
#    exit
#fi
LINE="==========================================="
SJVA_HOME=/mnt/c/sjva
DIR_DATA=$SJVA_HOME/data
DIR_BIN=$SJVA_HOME/bin/Linux
GIT1="https://github.com/soju6jan/sjva2_src_obfuscate"
GIT2="https://raw.githubusercontent.com/soju6jan/SJVA2"
PACKAGE_CMD="apt -y"
WHOAMI=`whoami`
START_SCRIPT=$SJVA_HOME/start_ubuntu.sh

menu() {
    clear
    echo -e " SJVA 설치 스크립트 v0.2 - wsl2 & ubuntu 20.04"
    echo $LINE
    echo -e "<Install>"
    echo "2. SJVA 설치 (최소)"
    echo "3. 파일브라우저(SJVA용) 설치"
    echo "4. rclone(SJVA용) 설치"
    echo "5. ffmpeg 설치" 
    echo "9. SJVA 설치 (전체)"
    echo $LINE
    echo "w. ps -ef"
    echo "x. stop sjva" 
    echo "z. SJVA foreground 실행"
    echo "0. 스크립트 업데이트"
    echo $LINE
}

base() {
    echo -e "\n\nSJVA 설치합니다."
    $PACKAGE_CMD update
    $PACKAGE_CMD upgrade 
    $PACKAGE_CMD install git wget python libxml2 python3-pip redis-server
    python3 -m pip install --upgrade pip 
    #pip3 install --upgrade setuptools
    pip3 install wheel==0.36.2
    pip3 install launchpadlib
    pip3 install gevent==20.9.0 lxml==4.6.2 Werkzeug==1.0.1 Jinja2==2.11.2 pycryptodome==3.9.9 SQLAlchemy==1.3.22   
    pip3 install aiohttp==3.7.3 amqp==5.0.2 APScheduler==3.6.3 async-timeout==3.0.1 attrs==20.3.0 billiard==3.6.3.0 celery==5.0.5 chardet==3.0.4 click==7.1.2 click-didyoumean==0.0.3 click-plugins==1.1.1 click-repl==0.1.6 Flask==1.1.2 Flask-Login==0.5.0 Flask-SocketIO==4.3.1 Flask-SQLAlchemy==2.4.4 gevent-websocket==0.10.1 greenlet==0.4.17 idna==2.10 itsdangerous==1.1.0  kombu==5.0.2  Markdown==3.3.3 MarkupSafe==1.1.1 multidict==5.1.0 prompt-toolkit==3.0.8 psutil==5.8.0  python-engineio==3.13.2 python-socketio==4.6.0 pytz==2020.4 redis==3.5.3 selenium==3.141.0 six==1.15.0 sqlitedict==1.7.0 telepot==12.7 typing-extensions==3.7.4.3 tzlocal==2.1 urllib3==1.26.2 vine==5.0.0 wcwidth==0.2.5 yarl==1.6.3 zope.event==4.5.0 zope.interface==5.2.0
    
    # sjva
    if [ -d $SJVA_HOME ]; then rm -rf $SJVA_HOME; fi
    git clone --depth 1 $GIT1  $SJVA_HOME

    # data folder
    mkdir -p $DIR_DATA
    ln -s $DIR_DATA $SJVA_HOME/data
    if [ ! -f "$SJVA_HOME/data/db/sjva.db" ]; then
        cd $SJVA_HOME && python3 sjva.py 0 0 init_db
    fi
    wget -O $START_SCRIPT https://raw.githubusercontent.com/soju6jan/sjva_support/master/wsl2_ubuntu/start_ubuntu.sh
    chmod +x $START_SCRIPT
    #service 
    
}

install_filebrowser() {
    echo -e "\n\n파일브라우저(SJVA용)를 설치합니다."
    mkdir -p $DIR_BIN
    ps -eo pid,args | grep filebrowser | grep -v grep | awk '{print $1}' | xargs -r kill -9
    rm -f $DIR_BIN/filebrowser
    wget -O $DIR_BIN/filebrowser https://raw.githubusercontent.com/soju6jan/SJVA2/master/bin/Linux/filebrowser
    chmod +x $DIR_BIN/filebrowser
    version=`$DIR_BIN/filebrowser version`
    echo -e "filebrowser 버전\n $version"
}

install_rclone() {
    echo -e "\n\nrclone(SJVA용)를 설치합니다."
    mkdir -p $DIR_BIN
    ps -eo pid,args | grep rclone | grep -v grep | awk '{print $1}' | xargs -r kill -9
    rm -f $DIR_BIN/rclone
    wget -O $DIR_BIN/rclone https://raw.githubusercontent.com/soju6jan/SJVA2/master/bin/Linux/rclone
    chmod +x $DIR_BIN/rclone
    version=`$DIR_BIN/rclone --version`
    echo -e "rclone 버전\n $version"
}

install_ffmpeg() {
    echo -e "\n\nffmpeg 설치를 시작합니다."
    $PACKAGE_CMD install --upgrade ffmpeg
}


all() {
    base
    install_filebrowser
    install_rclone
    install_ffmpeg
    #install_nginx
    #$PACKAGE_CMD install vim-python
    pip3 install pillow wcwidth google-api-python-client guessit plexapi
    pip3 install --upgrade youtube-dl
}


while true; do
    menu
    read -n 1 -s -p "메뉴 선택 > " cmd
    case $cmd in
        2)  base;;
        3)  install_filebrowser;;
        4)  install_rclone;;
        5)  install_ffmpeg;;
        9)  all;;
        w)  echo "`ps -ef`";;
        x)  $START_SCRIPT stop;;
        y)  echo -e "\n\nSJVA를 시작하였습니다."
            sv up sjva;;
        z)  echo $START_SCRIPT
            $START_SCRIPT stop
            cd $SJVA_HOME && $START_SCRIPT;;
        0)  echo -e "\n\n업데이트를 시작합니다."
            wget -O $SJVA_HOME/si https://raw.githubusercontent.com/soju6jan/sjva_support/master/wsl2_ubuntu/sjva_install.sh
            chmod +x $SJVA_HOME/si.sh
            mv $SJVA_HOME/si /usr/bin/si
            echo -e "\n\nsi를 재실행하세요."
            exit;;
        [\s\n]) ;;
        *)
            #$PACKAGE_CMD clean
            echo -e "\n\nsi입력시 이 스크립트가 실행됩니다."
            exit 1
    esac
    echo -e "\n"
    read -n 1 -s -r -p "아무키나 누르세요.."
done
exit
