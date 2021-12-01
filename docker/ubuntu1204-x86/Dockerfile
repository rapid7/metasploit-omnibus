# To build the dev environment.
# docker build -t rapid7/msf-ubuntu1204-x86-omnibus .
FROM i386/ubuntu:12.04
MAINTAINER Rapid7 Release Engineering <r7_re@rapid7.com>

RUN sed -i 's/archive\.ubuntu/old-releases\.ubuntu/g' /etc/apt/sources.list

RUN rm -fr /var/lib/apt/lists && \
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

RUN git config --global user.email "packager@example.com" && \
    git config --global user.name "Omnibus Packager"

ENV JENKINS_HOME /home/jenkins
RUN useradd -d "$JENKINS_HOME" -u 1001 -m -s /bin/sh jenkins

RUN mkdir -p "$JENKINS_HOME" && \
    cp ~/.gitconfig "$JENKINS_HOME" && \
    chown -R jenkins "$JENKINS_HOME" && \
    mkdir -p /var/cache/omnibus && \
    mkdir -p /opt/metasploit-framework && \
    chown jenkins /var/cache/omnibus && \
    chown jenkins /opt/metasploit-framework
RUN mkdir -p /etc/sudoers.d
RUN echo "jenkins    ALL=NOPASSWD: ALL" > /etc/sudoers.d/jenkins
RUN chmod 440 /etc/sudoers.d/jenkins

RUN su jenkins -c 'command curl --insecure -sSL https://rvm.io/mpapis.asc | gpg --import - && \
  command curl --insecure -sSL https://rvm.io/pkuczynski.asc | gpg --import - && \
  curl --insecure -L -sSL https://get.rvm.io | bash -s stable'

RUN su jenkins -c "/bin/bash -l -c 'rvm requirements'"
RUN su jenkins -c "linux32 /bin/bash -l -c 'rvm install 2.6.5'"
RUN su jenkins -c "linux32 /bin/bash -l -c 'gem install bundler -v 2.1.4 --no-document'"

# pre-load the omnibus dependencies
RUN su jenkins -c "/bin/bash -l -c 'cd ~/ && git clone https://github.com/rapid7/metasploit-omnibus.git && \
        cd ~/metasploit-omnibus && bundle install --binstubs && cd ~/ && rm -fr metasploit-omnibus'"
