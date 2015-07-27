name "metasploit-framework"
maintainer "Brent Cook <bcook@rapid7.com>"
homepage "https://rapid7.com"

install_dir "#{default_root}/metasploit-framework"

build_version Omnibus::BuildVersion.semver + "-1rapid7"
build_iteration 1

dependency "metasploit-framework-wrappers"

exclude "**/.git"
exclude "**/bundler/git"

package :msi do
  upgrade_code 'A3C83F57-6D8F-453A-9559-0D650A95EB21'
end
