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
    curl -L -sSL https://raw.githubusercontent.com/rvm/rvm/1.29.12/binscripts/rvm-installer | bash -s stable '

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

RUN curl --insecure --output ./sqlite.tar.gz 'https://www.sqlite.org/src/tarball/sqlite.tar.gz?r=release' && \
  echo "bc98a3e61d25882ee62c037c9513f65ba3a1a206e68edbf8e9a6514cbd7d4373  ./sqlite.tar.gz" > sqlite.tar.gz.sha256 && \
  sha256sum -c sqlite.tar.gz.sha256 && \
  tar zxf sqlite.tar.gz && \
  mkdir bld && cd bld && ../sqlite/configure && \
  make && make install && \
  cd ../ && rm -rf sqlite* && rm -rf bld && echo hello

# rvm autolibs disable
# RUN su jenkins -c "/bin/bash -l -c 'rvm requirements'"
# RUN su jenkins -c "/bin/bash -l -c 'rvm install 3.0.6'"
# RUN su jenkins -c "/bin/bash -l -c 'gem install bundler -v 2.2.3 --no-document'"

# pre-load the omnibus dependencies
# RUN su jenkins -c "/bin/bash -l -c 'cd ~/ && git clone https://github.com/rapid7/metasploit-omnibus.git && \
#         cd ~/metasploit-omnibus && bundle install && bundle binstubs --all && cd ~/ && rm -fr metasploit-omnibus'"
