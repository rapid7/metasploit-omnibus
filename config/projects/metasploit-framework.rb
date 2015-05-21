name "metasploit-framework"
maintainer "Brent Cook <bcook@rapid7.com>"
homepage "https://rapid7.com"

install_dir "#{default_root}/metasploit-framework"

build_version Omnibus::BuildVersion.semver
build_iteration 1

dependency "metasploit-framework"

exclude "**/.git"
exclude "**/bundler/git"
