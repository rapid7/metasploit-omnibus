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
    ccache \
    createrepo \
    expect \
	&& yum clean all

RUN curl -L https://www.opscode.com/chef/install.sh | bash
RUN git config --global user.email "packager@myco" && \
    git config --global user.name "Omnibus Packager"

RUN echo "export PATH=\${PATH}:/opt/chef/embedded/bin" | tee -a /etc/profile.d/chef-ruby.sh

RUN source /etc/profile.d/chef-ruby.sh && gem install bundler --no-ri --no-rdoc

# pre-load the omnibus dependencies
RUN git clone https://github.com/rapid7/metasploit-omnibus.git
RUN cd metasploit-omnibus && /opt/chef/embedded/bin/bundle install --binstubs
RUN rm -fr metasploit-omnibus

ENV JENKINS_HOME /var/jenkins_home
RUN useradd -d "$JENKINS_HOME" -u 1001 -m -s /bin/sh jenkins

RUN mkdir -p /var/cache/omnibus
RUN mkdir -p /opt/metasploit-framework
RUN chown jenkins /var/cache/omnibus
RUN chown jenkins /opt/metasploit-framework
RUN chown -R jenkins /opt/chef/embedded/lib/ruby/gems

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

ENV PATH /opt/chef/embedded/bin:$PATH
