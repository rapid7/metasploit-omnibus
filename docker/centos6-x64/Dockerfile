# To build the dev environment.
# docker build -t rapid7/msf-centos6-x64-omnibus .
FROM centos:centos6
MAINTAINER Rapid7 Release Engineering <r7_re@rapid7.com>

VOLUME /pkg

# # Copy newer apt sources that are valid/use https
COPY yum.repos.d /etc/yum.repos.d

RUN rpm -ivh https://dl.fedoraproject.org/pub/archive/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN yum upgrade -y && yum clean all

# TODO: This was skipped as a test and should most likely be added back in:
#       RUN yum install -y centos-release-SCL && yum clean all
#
# Reason:
#  => ERROR [ 5/26] RUN yum install -y centos-release-SCL && yum clean all                                                                                                                                                                                                              5.9s
# ------
#  > [ 5/26] RUN yum install -y centos-release-SCL && yum clean all:
# 0.986 Loaded plugins: fastestmirror, ovl
# 1.242 Setting up Install Process
# 1.242 Determining fastest mirrors
# 2.372  * epel: ftp-stud.hs-esslingen.de
# 5.668 No package centos-release-SCL available.
# 5.745 Error: Nothing to do
# ------
# Dockerfile:16
# --------------------
#   14 |     #
#   15 |
#   16 | >>> RUN yum install -y centos-release-SCL && yum clean all
#   17 |     RUN rpm --import http://mirrors.neterra.net/repoforge/RPM-GPG-KEY.dag.txt
#   18 |     RUN curl -O http://mirrors.neterra.net/repoforge/redhat/el6/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm && \
# --------------------
# ERROR: failed to solve: process "/bin/sh -c yum install -y centos-release-SCL && yum clean all" did not complete successfully: exit code: 1

RUN rpm --import http://mirrors.neterra.net/repoforge/RPM-GPG-KEY.dag.txt
RUN curl -O http://mirrors.neterra.net/repoforge/redhat/el6/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm && \
    rpm -i rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm && \
    rm rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm

RUN yum --enablerepo=rpmforge-extras install -y \
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
    fakeroot \
    git \
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
