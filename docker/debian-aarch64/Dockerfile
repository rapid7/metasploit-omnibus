# docker build -t rapid7/msf-debian-aarch64-omnibus .
FROM forumi0721/debian-aarch64-base:latest
MAINTAINER Rapid7 Release Engineering <r7_re@rapid7.com>

RUN ["docker-build-start"]

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
    procps \
    gnupg \
	build-essential \
    m4 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git config --global user.email "packager@example.com" && \
    git config --global user.name "Omnibus Packager"

RUN command curl -sSL https://rvm.io/mpapis.asc | gpg --import - && \
    command curl -sSL https://rvm.io/pkuczynski.asc | gpg --import - && \
    curl -L -sSL https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.5.3"
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

RUN ["docker-build-end"]
