FROM centos:centos6
MAINTAINER John E. Vincent

VOLUME /pkg

RUN rpm -ivh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN yum install -y centos-release-SCL

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
    fakeroot \
    git \
    ccache
RUN yum clean all


RUN curl -L https://www.opscode.com/chef/install.sh | bash
RUN git config --global user.email "packager@myco" && \
    git config --global user.name "Omnibus Packager"

RUN echo "export PATH=\${PATH}:/opt/chef/embedded/bin" | tee -a /etc/profile.d/chef-ruby.sh

RUN source /etc/profile.d/chef-ruby.sh && gem install bundler --no-ri --no-rdoc

# pre-load the omnibus dependencies
RUN git clone https://github.com/rapid7/metasploit-omnibus.git
RUN cd metasploit-omnibus && /opt/chef/embedded/bin/bundle install --binstubs
RUN rm -fr metasploit-omnibus
