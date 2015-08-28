name "metasploit-framework-extras"
maintainer "Rapid7 Release Engineering <r7_re@rapid7.com>"
homepage "https://rapid7.com"

install_dir "#{default_root}/metasploit-framework-extras"

build_version Omnibus::BuildVersion.semver
build_iteration 1

dependency "nmap"
dependency "john"
