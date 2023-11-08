# docker build -t rapid7/msf-debian-aarch64-omnibus .
FROM rapid7/msf-debian-aarch64-omnibus:2020_03
MAINTAINER Rapid7 Release Engineering <r7_re@rapid7.com>

RUN ["docker-build-start"]

# Copy newer apt sources that are valid/use https
COPY apt /etc/apt

# Update certs as the current ones have expired
RUN mkdir -p /tmp/updated_certs && \
    cd /tmp/updated_certs && \
    curl --location --insecure --output cacert-2023-08-22.pem https://curl.se/ca/cacert-2023-08-22.pem && \
    echo '23c2469e2a568362a62eecf1b49ed90a15621e6fa30e29947ded3436422de9b9  cacert-2023-08-22.pem' > cacert-2023-08-22.pem.sha256 && \
    sha256sum -c cacert-2023-08-22.pem.sha256 && \
    mv cacert-2023-08-22.pem /etc/ssl/certs/ca-certificates.crt && \
    rm -rf /tmp/updated_certs

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
    curl -L -sSL https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 3.0.6"
RUN /bin/bash -l -c "gem install bundler -v 2.2.3 --no-document"

# pre-load the omnibus dependencies
RUN /bin/bash -l -c 'cd ~/ && git clone https://github.com/rapid7/metasploit-omnibus.git && \
        cd ~/metasploit-omnibus && bundle install && bundle binstubs --all && cd ~/ && rm -fr metasploit-omnibus'

ENV JENKINS_HOME /home/jenkins
RUN useradd -d "$JENKINS_HOME" -u 1001 -m -s /bin/sh jenkins
RUN cp ~/.gitconfig "$JENKINS_HOME"
RUN chown -R jenkins "$JENKINS_HOME"

RUN mkdir -p /var/cache/omnibus
RUN mkdir -p /opt/metasploit-framework
RUN chown jenkins /var/cache/omnibus
RUN chown jenkins /opt/metasploit-framework
RUN chown -R jenkins /var/lib/gems/

RUN ["docker-build-end"]
