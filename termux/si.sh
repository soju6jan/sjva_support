#!/data/data/com.termux/files/usr/bin/bash
#LINE="========================================================"
if [ $0 != $PREFIX/bin/si ]; then
    mv -f $0 $PREFIX/bin/si
    chmod +x $PREFIX/bin/si
    exit
fi
LINE="==========================================="
SJVA_HOME=$HOME/sjva
DIR_DATA=$HOME/storage/downloads/sjva
DIR_BIN=$SJVA_HOME/bin/LinuxArm
GIT1="https://github.com/soju6jan/sjva2_src_obfuscate"
GIT2="https://raw.githubusercontent.com/soju6jan/SJVA2"
PACKAGE_CMD="apt -y"
WHOAMI=`whoami`

menu() {
    clear
    echo -e " SJVA 설치 스크립트 v0.2"
    echo $LINE
    echo -e "<Install>"
    echo "1. 저장소 접근 권한 허용 & 서비스 준비 (필수)"
    echo "2. SJVA 설치 (최소)"
    echo "3. 파일브라우저(SJVA용) 설치"
    echo "4. rclone(SJVA용) 설치"
    echo "5. ffmpeg 설치" 
    echo "6. nginx 설치"
    echo "9. SJVA 설치 (전체)"
    echo -e "\n<Tool>"
    echo "a. aria2 설치"
    echo "b. rclone 설치" 
    echo "c. sshd 설치"   
    echo "d. transmission 설치"
    echo "e. code-server 설치"
    echo "f. code-server 암호변경"
    echo $LINE
    echo "w. ps -ef"
    echo "x. kill all process" 
    echo "y. SJVA background 실행. z이용 후 복귀시만 사용"
    echo "z. SJVA foreground 실행"
    echo "0. 스크립트 업데이트"
    echo $LINE
}

base() {
    echo -e "\n\nSJVA 설치합니다."
    $PACKAGE_CMD update
    #$PACKAGE_CMD upgrade 
    $PACKAGE_CMD install termux-services git wget python libxml2 libxslt 
    python3 -m pip install --upgrade pip
    pip3 install --upgrade setuptools
    pip3 install wheel
    pip3 install flask-login flask-sqlalchemy pytz apscheduler selenium celery redis telepot sqlitedict lxml sqlalchemy gevent-websocket pycryptodome markdown psutil
    pip3 install flask-socketio==4.3.1 python-engineio==3.13.2 python-socketio==4.6.0

    # sjva
    if [ -d $SJVA_HOME ]; then rm -rf $SJVA_HOME; fi
    git clone --depth 1 $GIT1  $SJVA_HOME

    # data folder
    mkdir -p $DIR_DATA
    ln -s $DIR_DATA $SJVA_HOME/data
    if [ ! -f "$SJVA_HOME/data/db/sjva.db" ]; then
        cd $SJVA_HOME && python3 sjva.py 0 0 init_db
    fi
    #service 
    mkdir -p $PREFIX/var/service/sjva
    cat <<EOF >$PREFIX/var/service/sjva/run
#!/data/data/com.termux/files/usr/bin/sh
cd $HOME/sjva
bash ./start_termux_native.sh
EOF
    chmod +x $PREFIX/var/service/sjva/run
    sv-enable sjva
}

install_filebrowser() {
    echo -e "\n\n파일브라우저(SJVA용)를 설치합니다."
    mkdir -p $DIR_BIN
    ps -eo pid,args | grep filebrowser | grep -v grep | awk '{print $1}' | xargs -r kill -9
    rm -f $DIR_BIN/filebrowser
    uname=`uname -m`
    echo $uname
    if [ $uname == "aarch64" ]; then
        echo -e "64bit 설치\n"
        wget -O $DIR_BIN/filebrowser https://raw.githubusercontent.com/soju6jan/sjva_support/master/termux/filebrowser
    else
        echo -e "32bit 설치\n"
        wget -O $DIR_BIN/filebrowser https://raw.githubusercontent.com/soju6jan/sjva_support/master/termux/filebrowser_32
    fi
    chmod +x $DIR_BIN/filebrowser
    version=`$DIR_BIN/filebrowser version`
    echo -e "filebrowser 버전\n $version"
}

install_rclone() {
    echo -e "\n\nrclone(SJVA용)를 설치합니다."
    mkdir -p $DIR_BIN
    ps -eo pid,args | grep rclone | grep -v grep | awk '{print $1}' | xargs -r kill -9
    rm -f $DIR_BIN/rclone
    uname=`uname -m`
    echo $uname
    if [ $uname == "aarch64" ]; then
        echo -e "64bit 설치\n"
        wget -O $DIR_BIN/rclone https://raw.githubusercontent.com/soju6jan/sjva_support/master/termux/rclone
    else
        echo -e "32bit 설치\n"
        wget -O $DIR_BIN/rclone https://raw.githubusercontent.com/soju6jan/sjva_support/master/termux/rclone_32
    fi
    chmod +x $DIR_BIN/rclone
    version=`$DIR_BIN/rclone --version`
    echo -e "rclone 버전\n $version"
}

install_ffmpeg() {
    echo -e "\n\nffmpeg 설치를 시작합니다."
    $PACKAGE_CMD install --upgrade ffmpeg
}

install_nginx() {
    echo -e "\n\nnginx 설치를 시작합니다."
    $PACKAGE_CMD install --upgrade nginx php-fpm sqlite
    mkdir -p $SJVA_HOME/data/custom
    rm -rf $SJVA_HOME/data/custom/nginx
    git clone --depth 1 https://github.com/soju6jan/nginx $SJVA_HOME/data/custom/nginx
    mkdir -p $DIR_DATA/nginx
    cp -f $SJVA_HOME/data/custom/nginx/files/nginx.conf $DIR_DATA/nginx/nginx.conf
    echo $WHOAMI
    sed -i "s/root;/$WHOAMI;/" $DIR_DATA/nginx/nginx.conf
    sed -i "s@/etc/@$PREFIX/etc/@" $DIR_DATA/nginx/nginx.conf
    sed -i "s@/var/@$PREFIX/var/@" $DIR_DATA/nginx/nginx.conf
    sed -i "s@/app/@$SJVA_HOME/@" $DIR_DATA/nginx/nginx.conf
    sed -i "s/sub_filter/#sub_filter/" $DIR_DATA/nginx/nginx.conf
    sed -i "s@127.0.0.1:9000;@unix:/data/data/com.termux/files/usr/var/run/php-fpm.sock;@" $DIR_DATA/nginx/nginx.conf
    rm -rf $PREFIX/etc/nginx/nginx.conf
    ln -s $DIR_DATA/nginx/nginx.conf $PREFIX/etc/nginx/nginx.conf
    
    sqlite3 $SJVA_HOME/data/db/sjva.db "UPDATE system_setting SET value='19999' WHERE key='port'"
    #cp -f $SJVA_HOME/data/custom/nginx/files/php.ini $HOME/.php/php.ini
    mkdir -p $DIR_DATA/nginx/www
    cp -f $SJVA_HOME/data/custom/nginx/files/index.html $DIR_DATA/nginx/www/index.html
    cp -f $SJVA_HOME/data/custom/nginx/files/phpinfo.php $DIR_DATA/nginx/www/phpinfo.php
    cp -f $SJVA_HOME/data/custom/nginx/files/guide.php $DIR_DATA/nginx/www/guide.php
    sv-enable nginx
    sv-enable php-fpm
}

install_code_server() {
    echo -e "\n\ncode-server를 설치합니다.\n"
    $PACKAGE_CMD install nodejs yarn build-essential python
    yarn global add code-server
    mkdir -p $PREFIX/var/service/code
    cat <<EOF >$PREFIX/var/service/code/run
#!/data/data/com.termux/files/usr/bin/sh
exec code-server 
EOF
    chmod +x $PREFIX/var/service/code/run
    sv-enable code
}

install_code_server2() {
    echo -e "\n\n"
    read -r -p "사용할 암호를 입력하세요 > " new
    config="$HOME/.config/code-server/config.yaml"
    old=`sed -n '3p' $config | awk '{print $2}'`
    sed -i "s/$old/$new/" $config           
    sv restart code
}

stop_sjva() {
    sv stop sjva
    ps -eo pid,args | grep start_termux_native | grep -v grep | awk '{print $1}' | xargs -r kill -9
    ps -eo pid,args | grep sjva.py | grep -v grep | awk '{print $1}' | xargs -r kill -9
}

all() {
    base
    install_filebrowser
    install_rclone
    install_ffmpeg
    install_nginx
    $PACKAGE_CMD install vim-python
    pip3 install pillow wcwidth google-api-python-client guessit plexapi
}

install_aria() {
    echo -e "\n\naria2 설치를 시작합니다."
    $PACKAGE_CMD install aria2
    echo -e "\n\nSJVA nginx 플러그인에서 웹 UI를 설치하세요."
}

close() {
    sv stop sshd
    sv stop nginx
    sv stop php-fpm
    sv stop code
    sv stop transmission
    stop_sjva
    ps -eo pid,args | grep sv | grep -v grep | awk '{print $1}' | xargs -r kill -9
    sleep 1
    ps -ef
    
}

while true; do
    menu
    read -n 1 -s -p "메뉴 선택 > " cmd
    case $cmd in
        1)  echo -e "\n\n권한을 허용해주세요."
            termux-setup-storage
            $PACKAGE_CMD update
            $PACKAGE_CMD install termux-services
            close
            echo -e "\n\nTermux 강제 중지 or exit 입력하여 종료 후 재실행하여 si를 입력하세요."
            exit;;
        2)  base;;
        3)  install_filebrowser;;
        4)  install_rclone;;
        5)  install_ffmpeg;;
        6)  install_nginx;;
        9)  all;;
        a)  echo -e "\n\naria2 설치를 시작합니다."
            $PACKAGE_CMD install aria2
            echo -e "\nSJVA nginx 플러그인에서 웹 UI를 설치하세요.";;
        b)  echo -e "\n\nrclone 설치를 시작합니다."
            $PACKAGE_CMD install rclone
            version=`rclone --version`
            echo -e "rclone 버전\n $version";;
        c)  echo -e "\n\nsshd 설치를 시작합니다."
            $PACKAGE_CMD install openssh
            echo -e "\n암호를 입력하세요\n"
            passwd
            echo "IP : `ifconfig wlan0`"
            echo "PORT : 8022"
            echo -e "USER : $WHOAMI"
            sv-enable sshd;;
        d)  echo -e "\n\ntransmission 설치를 시작합니다."
            $PACKAGE_CMD install transmission
            if [ ! -d $PREFIX/share/transmission/web_default ]; then
                mv $PREFIX/share/transmission/web $PREFIX/share/transmission/web_default
            else
                rm -rf $PREFIX/share/transmission/web
            fi
            git clone https://github.com/ronggang/transmission-web-control $HOME/twc
            mv $HOME/twc/src $PREFIX/share/transmission/web
            rm -rf $HOME/twc
            echo -e "\n\nlocalhost:9091 or localhost:9999/transmission"
            sv-enable transmission;;
        e)  install_code_server;;
        f)  install_code_server2;;
        w)  echo "`ps -ef`";;
        x)  close
            echo -e "\n\nexit 명령을 입력하여 Termux를 종료하세요"
            exit;;
        y)  echo -e "\n\nSJVA를 시작하였습니다."
            sv up sjva;;
        z)  stop_sjva
            $PREFIX/var/service/sjva/run;;
        0)  echo -e "\n\n업데이트를 시작합니다."
            wget -O $HOME/si.sh https://raw.githubusercontent.com/soju6jan/sjva_support/master/termux/si.sh
            chmod +x $HOME/si.sh
            mv $HOME/si.sh $PREFIX/bin/si
            echo -e "\n\n재실행하세요."
            exit;;
        [\s\n]) ;;
        *)
            #$PACKAGE_CMD clean
            echo -e "\n\n설치된 서비스가 있다면 Termux를 재시작하세요.\nsi입력시 이 스크립트가 실행됩니다."
            exit 1
    esac
    echo -e "\n"
    read -n 1 -s -r -p "아무키나 누르세요.."
done
exit
