FROM rapid7/build:kali109_64
MAINTAINER Brent Cook

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

RUN gem install bundler --no-ri --no-rdoc

# pre-load the omnibus dependencies
RUN git clone https://github.com/rapid7/metasploit-omnibus.git
RUN cd metasploit-omnibus && bundle install --binstubs
RUN rm -fr metasploit-omnibus

ENV JENKINS_HOME /var/jenkins_home
RUN cp ~/.gitconfig "$JENKINS_HOME"
RUN chown -R jenkins "$JENKINS_HOME"

RUN mkdir -p /var/cache/omnibus
RUN mkdir -p /opt/metasploit-framework
RUN chown jenkins /var/cache/omnibus
RUN chown jenkins /opt/metasploit-framework
RUN chown -R jenkins /var/lib/gems/
RUN echo "jenkins    ALL=NOPASSWD: ALL" > /etc/sudoers.d/jenkins
RUN chmod 440 /etc/sudoers.d/jenkins
