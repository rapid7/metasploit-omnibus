#
# Copyright 2015 Brent Cook
#
# All Rights Reserved.
#

name "metasploit"
maintainer "Brent Cook <bcook@rapid7.com>"
homepage "https://rapid7.com"

# Defaults to C:/metasploit on Windows
# and /opt/metasploit on all other platforms
install_dir "#{default_root}/#{name}"

build_version Omnibus::BuildVersion.semver
build_iteration 1

dependency "metasploit-framework"

# Creates required build directories
#dependency "preparation"

# metasploit dependencies/components
# dependency "somedep"

# Version manifest file

exclude "**/.git"
exclude "**/bundler/git"
