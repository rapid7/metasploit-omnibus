# To build the dev environment.
# docker build -t rapid7/msf-kali109-x64-omnibus .
FROM rapid7/build:kali109_64
MAINTAINER Rapid7 Release Engineering <r7_re@rapid7.com>

# package/ruby: needs gcc and host gcc >= 4.9, available only in Sana - https://www.kali.org/blog/kali-moto-eol/
RUN echo "deb http://old.kali.org/kali sana main non-free contrib" > /etc/apt/sources.list

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
    gawk \
    pkg-config \
    sqlite3 \
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

RUN curl -O ftp://ftp.tcl.tk/pub/tcl/tcl8_6/tcl8.6.9-src.tar.gz && \
  tar zxf tcl8.6.9-src.tar.gz && \
  cd tcl8.6.9/unix && \
  ./configure && make && make install && \
  cd ../../ && rm -rf tcl8.6.9*

# Update certs to fix later git clone issues:
#   error: server certificate verification failed. CAfile: /etc/ssl/certs/ca-certificates.crt CRLfile: none while accessing https://github.com/rapid7/metasploit-omnibus.git/info/refs
# We extract a new https://curl.se/docs/caextract.html bundle using the sha256summ
# from https://curl.se/ca/cacert-2023-08-22.pem.sha256
RUN mkdir -p /tmp/updated_certs && \
    cd /tmp/updated_certs && \
    curl --location --insecure --output cacert-2023-08-22.pem https://curl.se/ca/cacert-2023-08-22.pem && \
    echo '23c2469e2a568362a62eecf1b49ed90a15621e6fa30e29947ded3436422de9b9  cacert-2023-08-22.pem' > cacert-2023-08-22.pem.sha256 && \
    sha256sum -c cacert-2023-08-22.pem.sha256 && \
    mv cacert-2023-08-22.pem /etc/ssl/certs/ca-certificates.crt && \
    rm -rf /tmp/updated_certs

RUN su jenkins -c "/bin/bash -l -c 'rvm requirements'"
RUN su jenkins -c "/bin/bash -l -c 'rvm install 3.0.6'"
RUN su jenkins -c "/bin/bash -l -c 'gem install bundler -v 2.2.3 --no-document'"

# pre-load the omnibus dependencies
RUN su jenkins -c "/bin/bash -l -c 'cd ~/ && git clone https://github.com/rapid7/metasploit-omnibus.git && \
        cd ~/metasploit-omnibus && bundle install && bundle binstubs --all && cd ~/ && rm -fr metasploit-omnibus'"
