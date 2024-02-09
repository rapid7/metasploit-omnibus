.DEFAULT_GOAL := all

.PHONY: all
all:
	# TODO: Should be conditional
	export SSL_CERT_FILE=/metasploit-omnibus/certs/ca-certificates.crt;

	# Ensure consistent bundler versions
	gem install bundler -v 2.2.3

	# install omnibus' dependencies
	bundle install
	bundle binstubs --all

	# build the metasploit-framework package
	bin/omnibus build metasploit-framework

.PHONY: clean
clean:
	bin/omnibus clean metasploit-framework
