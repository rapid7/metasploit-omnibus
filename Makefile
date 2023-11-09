.DEFAULT_GOAL := all

.PHONY: all
all: certs/ca-certificates.crt
	# export SSL_CERT_FILE=${PWD}/certs/ca-certificates.crt

	# Ensure consistent bundler versions
	gem install bundler -v 2.2.3

	# install omnibus' dependencies
	bundle install
	bundle binstubs --all

	gem install win32-process -v 0.9.0

	# build the metasploit-framework package
	ruby bin/omnibus build metasploit-framework

certs/ca-certificates.crt:
	mkdir -p certs
	curl -L -o certs/ca-certificates.crt https://curl.haxx.se/ca/cacert.pem

.PHONY: clean
clean:
	bin/omnibus clean metasploit-framework
