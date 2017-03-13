# docker build -t rapid7/build:msf-omnibus-debian-armv7 .
FROM resin/armv7hf-debian-qemu
MAINTAINER Rapid7 Release Engineering <r7_re@rapid7.com>

RUN ["cross-build-start"]

RUN apt-get update && apt-get install -y \
    git \
    curl \
    autoconf \
    binutils-doc \
    bison \
    flex \
    gettext \
    build-essential \
    ruby \
    rsync \
    ccache \
    devscripts \
    fakeroot \
    unzip \
	build-essential \
    m4 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git config --global user.email "packager@example.com" && \
    git config --global user.name "Omnibus Packager"

RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import -
RUN curl -sSL https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.3.3"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"

RUN gem install bundler --no-ri --no-rdoc

# pre-load the omnibus dependencies
RUN git clone https://github.com/rapid7/metasploit-omnibus.git
RUN cd metasploit-omnibus && /bin/bash -l -c "bundle install --binstubs"
RUN rm -fr metasploit-omnibus

ENV JENKINS_HOME /home/jenkins
RUN useradd -d "$JENKINS_HOME" -u 1001 -m -s /bin/sh jenkins
RUN cp ~/.gitconfig "$JENKINS_HOME"
RUN chown -R jenkins "$JENKINS_HOME"

RUN mkdir -p /var/cache/omnibus
RUN mkdir -p /opt/metasploit-framework
RUN chown jenkins /var/cache/omnibus
RUN chown jenkins /opt/metasploit-framework
RUN chown -R jenkins /var/lib/gems/

RUN ["cross-build-end"]
