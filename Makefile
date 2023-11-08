.DEFAULT_GOAL := all

.PHONY: all
all:
	# install omnibus' dependencies
	bundle install
	bundle binstubs --all

	# build the metasploit-framework package
	bin/omnibus build metasploit-framework

.PHONY: clean
clean:
	bin/omnibus clean metasploit-framework
