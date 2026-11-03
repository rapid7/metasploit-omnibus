# docker build -t rapid7/msf-debian-aarch64-omnibus .
FROM rapid7/msf-debian-aarch64-omnibus:2020_03
MAINTAINER Rapid7 Release Engineering <r7_re@rapid7.com>

RUN ["docker-build-start"]

# Copy newer apt sources that are valid/use https
COPY apt /etc/apt

# The legacy base image has expired CA roots. Vendor the repository-maintained
# bundle into this Docker build context rather than downloading it insecurely.
COPY ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

# Import newer debian signing keys, as the current version available in the docker image is outdated and apt-get fails
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0E98404D386FA1D9 6ED0E7B82643E131 F8D2585B8783D481

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
    curl --fail --location --silent --show-error --output /tmp/rvm-installer https://raw.githubusercontent.com/rvm/rvm/1.29.12/binscripts/rvm-installer && \
    echo 'fea24461e98d41528d6e28684aa4c216dbe903869bc3fcdb3493b6518fae2e7e  /tmp/rvm-installer' | sha256sum -c - && \
    /bin/bash /tmp/rvm-installer stable && \
    rm -f /tmp/rvm-installer
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 3.0.6"
RUN /bin/bash -l -c "gem install bundler -v 2.2.3 --no-document"

# pre-load the omnibus dependencies
RUN /bin/bash -l -c 'cd ~/ && git clone https://github.com/rapid7/metasploit-omnibus.git && \
        cd ~/metasploit-omnibus && bundle install && bundle binstubs --all && cd ~/ && rm -fr metasploit-omnibus'

ENV JENKINS_HOME /home/jenkins
RUN id jenkins || useradd -d "$JENKINS_HOME" -u 1001 -m -s /bin/sh jenkins
RUN cp ~/.gitconfig "$JENKINS_HOME"
RUN chown -R jenkins "$JENKINS_HOME"
RUN echo "jenkins ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

RUN mkdir -p /var/cache/omnibus
RUN mkdir -p /opt/metasploit-framework
RUN chown jenkins /var/cache/omnibus
RUN chown jenkins /opt/metasploit-framework
RUN chown -R jenkins /var/lib/gems/

RUN ["docker-build-end"]
