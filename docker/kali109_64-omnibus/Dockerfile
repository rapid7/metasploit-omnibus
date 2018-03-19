# To build the dev environment.
# docker build -t rapid7/build:kali109_64-omnibus .
FROM rapid7/build:kali109_64
MAINTAINER Rapid7 Release Engineering <r7_re@rapid7.com>

RUN rm -fr /var/lib/apt/lists && \
    apt-get update && \
	apt-get install -y --force-yes kali-archive-keyring && \
	apt-get update && \
	apt-get install -y \
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

RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import -
RUN curl -sSL https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.1"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"

# pre-load the omnibus dependencies
RUN git clone https://github.com/rapid7/metasploit-omnibus.git
RUN /bin/bash -l -c "cd metasploit-omnibus && bundle install --binstubs"
RUN rm -fr metasploit-omnibus
RUN mkdir /metasploit-framework
RUN /usr/bin/sudo rm -rf $HOME/.rvm $HOME/.rvmrc /etc/rvmrc /etc/profile.d/rvm.sh /usr/local/rvm /usr/local/bin/rvm && \
  /usr/bin/sudo /usr/sbin/groupdel rvm
RUN su jenkins -c "/bin/bash -l -c 'curl -sSL https://rvm.io/mpapis.asc | gpg --import -'"
RUN su jenkins -c "/bin/bash -l -c 'curl -sSL https://get.rvm.io | bash -s stable'"
RUN su jenkins -c "/bin/bash -l -c 'rvm install 2.4.1'"
RUN su jenkins -c "/bin/bash -l -c 'rvm use 2.4.1 && gem install bundler --no-ri --no-rdoc'"
RUN su jenkins -c "/bin/bash -l -c 'rvm use 2.4.1 && cd ~/ && git clone https://github.com/rapid7/metasploit-omnibus.git && \
  cd metasploit-omnibus && bundle install --binstubs && cd .. && rm -rf metasploit-omnibus'"
