# To build the dev environment.
# docker build -t rapid7/msf-fedora30-x64-omnibus .
FROM fedora:30
MAINTAINER Rapid7 Release Engineering <r7_re@rapid7.com>

VOLUME /pkg

RUN yum upgrade -y && yum clean all

RUN yum install -y \
    autoconf \
    bison \
    flex \
    gcc \
    gcc-c++ \
    kernel-devel \
    make \
    m4 \
    patch \
    openssl-devel \
    expat-devel \
    perl-ExtUtils-MakeMaker \
    curl-devel \
    tar \
    unzip \
    libxml2-devel \
    libxslt-devel \
    ncurses-devel \
    zlib-devel \
    rsync \
    rpm-build \
    rpm-sign \
    fakeroot \
    git \
    gpg \
    procps \
    which \
    ccache \
    createrepo \
    expect \
    sudo \
	&& yum clean all

RUN curl -L https://www.opscode.com/chef/install.sh | bash
RUN git config --global user.email "packager@myco" && \
    git config --global user.name "Omnibus Packager"

ENV JENKINS_HOME /var/jenkins_home
RUN useradd -d "$JENKINS_HOME" -u 1001 -m -s /bin/sh jenkins

RUN mkdir -p /var/cache/omnibus
RUN mkdir -p /opt/metasploit-framework
RUN chown jenkins /var/cache/omnibus
RUN chown jenkins /opt/metasploit-framework

RUN echo "#!/usr/bin/expect -f" > /usr/bin/signrpm && \
	echo "spawn rpm --addsign {*}\$argv" >> /usr/bin/signrpm && \
	echo "expect -exact \"Enter pass phrase: \"" >> /usr/bin/signrpm && \
	echo "send -- \"\r\"" >> /usr/bin/signrpm && \
	echo "expect eof" >> /usr/bin/signrpm
RUN chmod 755 /usr/bin/signrpm

RUN cp ~/.gitconfig "$JENKINS_HOME"
RUN echo "%_signature gpg" > "$JENKINS_HOME/.rpmmacros" && \
	echo "%_gpg_name 35AF4DDB" >> "$JENKINS_HOME/.rpmmacros" && \
	echo "%__gpg_check_password_cmd /bin/true" >> "$JENKINS_HOME/.rpmmacros" && \
	echo "%__gpg_sign_cmd %{__gpg} gpg --batch --no-verbose --no-armor --use-agent --no-secmem-warning -u \"%{_gpg_name}\" -sbo %{__signature_filename} %{__plaintext_filename}" >> "$JENKINS_HOME/.rpmmacros"
RUN chown -R jenkins "$JENKINS_HOME"
RUN echo "jenkins ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

RUN su jenkins -c 'command curl -sSL https://rvm.io/mpapis.asc | gpg --import - && \
  command curl -sSL https://rvm.io/pkuczynski.asc | gpg --import - && \
  curl -L -sSL https://raw.githubusercontent.com/rvm/rvm/1.29.12/binscripts/rvm-installer | bash -s stable'

RUN su jenkins -c "/bin/bash -l -c 'rvm requirements'"
RUN su jenkins -c "/bin/bash -l -c 'rvm install 3.0.6'"
RUN su jenkins -c "/bin/bash -l -c 'gem install bundler -v 2.2.3 --no-document'"
# pre-load the omnibus dependencies
RUN su jenkins -c "/bin/bash -l -c 'cd ~/ && git clone https://github.com/rapid7/metasploit-omnibus.git && \
        cd ~/metasploit-omnibus && bundle install && bundle binstubs --all && cd ~/ && rm -fr metasploit-omnibus'"
