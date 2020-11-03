#!/data/data/com.termux/files/usr/bin/bash
#LINE="========================================================"
mv $0 $PREFIX/bin/si
chmod +x $PREFIX/bin/si
LINE="==========================================="
SJVA_HOME=$HOME/sjva
DIR_DATA=$HOME/storage/downloads/sjva
DIR_BIN=$HOME/bin/LinuxArm
GIT1="https://github.com/soju6jan/sjva2_src_obfuscate"
GIT2="https://raw.githubusercontent.com/soju6jan/SJVA2"
PACKAGE_CMD="apt"
WHOAMI=`whoami`

menu() {
    clear
    echo $LINE
    echo -e " SJVA 설치 스크립트 v0.1"
    echo $LINE
    echo -e "<Debug>"
    echo "0. SJVA foreground 실행"
    echo -e "\n<Install>"
    echo "1. 저장소 접근 권한 허용"
    echo "2. SJVA 설치 (최소)"
    echo "3. 파일브라우저(SJVA용) 설치"
    echo "4. rclone(SJVA용) 설치 "
    echo "5. ffmpeg 설치" 
    echo "6. nginx 설치"
    echo "9. SJVA 설치 (전체)"
    echo -e "\nTool"
    echo "a. aria2c 설치"
    echo "b. rclone 설치"    
    echo "c. transmission 설치"
    echo "d. sshd 설치"
    echo "e. code-server 설치"    
    echo $LINE
}

base() {
    echo -e "\n\nSJVA 설치합니다."
    $PACKAGE_CMD -y update
    #$PACKAGE_CMD -y upgrade 
    $PACKAGE_CMD -y install termux-services git wget python libxml2 libxslt 
    python3 -m pip install --upgrade pip
    pip3 install --upgrade setuptools
    pip3 install wheel
    pip3 install flask-login flask-socketio flask-sqlalchemy pytz apscheduler selenium celery redis telepot sqlitedict lxml sqlalchemy gevent-websocket pycryptodome markdown psutil

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
bash ./s.sh
EOF
    chmod +x $PREFIX/var/service/sjva/run
    sv-enable sjva
}



install_filebrowser() {
    echo -e "\n\n파일브라우저(SJVA용)를 설치합니다."
    mkdir -p $DIR_BIN
    wget -O $DIR_BIN/filebrowser $GIT2/master/bin/LinuxArm/filebrowser
    chmod +x $DIR_BIN/filebrowser
    version=`$DIR_BIN/filebrowser version`
    echo -e "filebrowser 버전\n $version"
}

install_rclone() {
    echo -e "\n\nrclone(SJVA용)를 설치합니다."
    mkdir -p $DIR_BIN
    wget -O $DIR_BIN/rclone $GIT2/master/bin/LinuxArm/rclone
    chmod +x $DIR_BIN/rclone
    version=`$DIR_BIN/rclone --version`
    echo -e "rclone 버전\n $version"
}

install_ffmpeg() {
    echo -e "\n\nffmpeg 설치를 시작합니다."
    $PACKAGE_CMD -y install --upgrade ffmpeg
}

install_nginx() {
    echo -e "\n\nnginx 설치를 시작합니다."
    $PACKAGE_CMD -y install --upgrade nginx php-fpm sqlite
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
    read -r -p "사용할 암호를 입력하세요 > " new
    pkg install nodejs yarn build-essential python
    yarn global add code-server
    config="$HOME/.config/code-server/config.yaml"
    old=`sed -n '3p' $config | awk '{print $2}'`
    sed -i "s/$old/$new/" $config           
    mkdir -p $PREFIX/var/service/code
    cat <<EOF >$PREFIX/var/service/code/run
#!/data/data/com.termux/files/usr/bin/sh
exec code-server
EOF
    chmod +x $PREFIX/var/service/code/run
    sv-enable code
}

all() {
    base
    install_filebrowser
    install_rclone
    install_ffmpeg
    install_nginx
    $PACKAGE_CMD -y install vim-python
    pip3 install pillow wcwidth google-api-python-client guessit plexapi
}

while true; do
    menu
    read -n 1 -r -p "메뉴 선택 > " cmd
    case $cmd in
        1) 
            echo -e "\n\n권한을 허용해주세요."
            termux-setup-storage;;
        2) base;;
        3) install_filebrowser;;
        4) install_rclone;;
        5) install_ffmpeg;;
        6) install_nginx;;
        9) all;;
        e) install_code_server;;
        *)
            echo "AAA $cmd BBB"
            #$PACKAGE_CMD clean
            echo -e "\n\n스크립트를 종료합니다.\n설치된 패키지가 있다면 Termux를 재시작하세요."
            exit 1
    esac
    echo -e "\n"
    read -n 1 -s -r -p "아무키나 누르세요.."
done
exit
