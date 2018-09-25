#!/bin/bash

apt-get update


if [ "$(id -u)" != "0" ]; then
    echo "you should run this script with root!!! "
    exit 1
else

    
#intalação go lang

    donwload="go$VERSION.linux-amd64.tar.gz"


    echo "$dowload is being downloaded !!!!"
    wget https://storage.googleapis.com/golang/$dowload -O /tmp/go.tar.gz

    tar -C "$HOME" -xzf /tmp/go.tar.gz
    mv "$HOME/go" "$HOME/.go"
    touch "$HOME/.${shell_profile}"
    {
        echo '# GoLang'
        echo 'export GOROOT=$HOME/.go'
        echo 'export PATH=$PATH:$GOROOT/bin'
        echo 'export GOPATH=$HOME/go'
        echo 'export PATH=$PATH:$GOPATH/bin'
    } >> "$HOME/.${shell_profile}"

    mkdir -p $HOME/go/{src,pkg,bin}
    echo -e "\nGo $VERSION was installed.\nMake sure to relogin into your shell or run:"
    echo -e "\n\tsource $HOME/.${shell_profile}\n\nto update your environment variables."
    echo "Tip: Opening a new terminal window usually just works. :)"
    rm -f /tmp/go.tar.gz

#gogs installation


    MY_IP=$(ip a s|sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}' | tr '\n' ' ')

  

    echo "" >>/etc/hosts
    echo "$1  $2" >>/etc/hosts
    hostnamectl set-hostname $2
    echo "$2" > /proc/sys/kernel/hostname

    apt-get install -y wget nginx git-core mysql-client mysql-server
    adduser --disabled-login --gecos 'Gogs' git

    cd /home/git
    wget --no-check-certificate https://dl.gogs.io/0.11.4/linux_amd64.tar.gz
    tar -xvf linux_amd64.tar.gz && rm -f linux_amd64.tar.gz

    echo "CREATE USER 'gogs'@'localhost' IDENTIFIED BY $3;" >>/home/git/gogs/scripts/mysql.sql
    echo "GRANT ALL PRIVILEGES ON gogs.* TO 'gogs'@'localhost';" >>/home/git/gogs/scripts/mysql.sql 

    echo "--------------------"
    mysql -p < /home/git/gogs/scripts/mysql.sql

    chmod +x /home/git/gogs/gogs
    mkdir -p /home/git/gogs/log

    chown -R git:git /home/git/gogs
    chown -R git:git /home/git/gogs/*

    cp /home/git/gogs/scripts/systemd/gogs.service /etc/systemd/system/
    sed -i 's|mysqld.service|mysqld.service mysql.service|' /etc/systemd/system/gogs.service

    systemctl daemon-reload
    systemctl enable gogs.service
    systemctl start gogs.service


    echo 'server {
        listen          IP:80;
        server_name     DOMAIN;

        proxy_set_header X-Real-IP  $remote_addr; # pass on real client IP

        location / {
            proxy_pass http://localhost:3000;
        }
    }' > /etc/nginx/sites-available/gogs.conf

    ln -s /etc/nginx/sites-available/gogs.conf /etc/nginx/sites-enabled/gogs.conf

    sed -i "s/IP/$1/" /etc/nginx/sites-available/gogs.conf
    sed -i "s/DOMAIN/$2/" /etc/nginx/sites-available/gogs.conf
    service nginx restart

    echo "installation completed"

fi
