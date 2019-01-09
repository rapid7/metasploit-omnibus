# To build the dev environment.
# docker build -t rapid7/msf-kali109-x64-omnibus .
FROM rapid7/build:kali109_64
MAINTAINER Rapid7 Release Engineering <r7_re@rapid7.com>

RUN echo "deb http://old.kali.org/kali moto main non-free contrib" > /etc/apt/sources.list

RUN rm -fr /var/lib/apt/lists && \
    apt-get update && \
	apt-get install -y --force-yes kali-archive-keyring && \
	apt-get update && \
	apt-get install -y --force-yes \
    curl \
    binutils-doc \
    flex \
	ruby ruby-dev \
    ccache \
    fakeroot \
    libreadline-dev \
    libcurl4-openssl-dev \
    libexpat1-dev \
    libicu-dev \
	reprepro && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git config --global user.email "packager@example.com" && \
    git config --global user.name "Omnibus Packager"

ENV JENKINS_HOME /home/jenkins
RUN mkdir -p "$JENKINS_HOME" && \
	cp ~/.gitconfig "$JENKINS_HOME" && \
	chown -R jenkins "$JENKINS_HOME" && \
	mkdir -p /var/cache/omnibus && \
	mkdir -p /opt/metasploit-framework && \
	chown jenkins /var/cache/omnibus && \
	chown jenkins /opt/metasploit-framework
RUN echo "jenkins    ALL=NOPASSWD: ALL" > /etc/sudoers.d/jenkins
RUN chmod 440 /etc/sudoers.d/jenkins
RUN apt-get remove -y libpq-dev libpq5

RUN su jenkins -c 'command curl -sSL https://rvm.io/mpapis.asc | gpg --import - && \
  command curl -sSL https://rvm.io/pkuczynski.asc | gpg --import - && \
  curl -L -sSL https://get.rvm.io | bash -s stable'

RUN curl -O http://ftp.gnu.org/gnu/gawk/gawk-4.2.1.tar.gz && \
  tar zxf gawk-4.2.1.tar.gz && \
  cd gawk-4.2.1 && \
  ./configure && \
  make && make install && \
  cd ../ && rm -rf gawk-4.2.1*

RUN curl -O ftp://ftp.tcl.tk/pub/tcl/tcl8_6/tcl8.6.9-src.tar.gz && \
  tar zxf tcl8.6.9-src.tar.gz && \
  cd tcl8.6.9/unix && \
  ./configure && make && make install && \
  cd ../../ && rm -rf tcl8.6.9*

RUN curl -O https://www.sqlite.org/src/tarball/sqlite.tar.gz?r=release && \
  tar zxf sqlite.tar.gz?r=release && \
  mkdir bld && cd bld && ../sqlite/configure && \
  make && make install && \
  cd ../ && rm -rf sqlite* && rm -rf bld

# pre-load the omnibus dependencies
RUN su jenkins -c "/bin/bash -l -c 'rvm install 2.5.3 --autolibs=0'"
RUN su jenkins -c "/bin/bash -l -c 'rvm use 2.5.3 && gem install bundler --no-ri --no-rdoc'"
RUN su jenkins -c "/bin/bash -l -c 'rvm use 2.5.3 && cd ~/ && git clone https://github.com/rapid7/metasploit-omnibus.git && \
  cd metasploit-omnibus && bundle install --binstubs && cd .. && rm -rf metasploit-omnibus'"
