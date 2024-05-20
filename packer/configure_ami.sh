#!/bin/bash

if [ "$EUID" != 0 ]; then
  echo "WARNING: Script should be run as root."
  sleep 3
fi

export BUILD_DIR=`pwd`
export DOCKER_FLAGS=""

set -ex

apt-get update

apt-get install -y wget bsdmainutils

# docker-ce latest
apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu
curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose

rm -fr /var/lib/apt/lists && \
    apt-get update && \
    apt-get install -y \
        curl \
        binutils-doc \
        flex \
        git \
        ruby ruby-dev \
        ccache \
        fakeroot \
        libreadline-dev \
        libcurl4-openssl-dev \
        libexpat1-dev \
        libicu-dev \
        reprepro \
        sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

git config --global user.email "packager@example.com" && \
git config --global user.name "Omnibus Packager"

export BUILD_USER="ubuntu"
export USER_HOME="/home/$BUILD_USER"
cp ~/.gitconfig "$USER_HOME" && \
    chown -R $BUILD_USER:$BUILD_USER $USER_HOME && \
    chown -R $BUILD_USER "$USER_HOME" && \
    mkdir -p /var/cache/omnibus && \
    mkdir -p /opt/metasploit-framework && \
    chown $BUILD_USER  /var/cache/omnibus && \
    chown $BUILD_USER /opt/metasploit-framework

su $BUILD_USER -c 'command curl -sSL https://rvm.io/mpapis.asc | gpg --import - && \
  command curl -sSL https://rvm.io/pkuczynski.asc | gpg --import - && \
  curl -L -sSL https://raw.githubusercontent.com/rvm/rvm/1.29.12/binscripts/rvm-installer | bash -s stable'

su $BUILD_USER -c "/bin/bash -l -c 'rvm requirements'"
su $BUILD_USER -c "/bin/bash -l -c 'rvm install 3.0.6'"
su $BUILD_USER -c "/bin/bash -l -c 'gem install bundler -v 2.2.3 --no-document'"
su $BUILD_USER -c "/bin/bash -l -c 'cd ~/ && git clone https://github.com/rapid7/metasploit-omnibus.git && \
        cd ~/metasploit-omnibus && bundle install && bundle binstubs --all && cd ~/ && rm -fr metasploit-omnibus'"

# Remove Aptitude daily cron jobs
systemctl disable apt-daily.service
systemctl disable apt-daily.timer
systemctl disable apt-daily-upgrade.timer
systemctl disable apt-daily-upgrade.service

# Wipe /etc/rc.local
echo '#!/bin/sh' > /etc/rc.local
chmod u+x /etc/rc.local

# Cleanup build files, logs and histories
rm -rf /var/log/auth.log* /var/log/syslog     # Cleanup system logs
rm -rf ~/.bash_history                        # Cleanup root's history
rm -rf ~ubuntu/* ~ubuntu/.bash_history        # Cleanup ubuntu's home and history
unset HISTFILE                                # Prevent this session's history from being written

docker system prune -f
docker ps -a
docker images -a

echo Done && exit

