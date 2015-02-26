name "metasploit-framework"
default_version "4.11.1"
source url: "https://github.com/rapid7/metasploit-framework/archive/4.11.1.tar.gz",
       md5: "8194917a8b5e53f9f72e8ba55df8c8cf"

dependency "bundler"
dependency "liblzma"
dependency "libpcap"
dependency "ruby"
dependency "postgresql"
dependency "sqlite"

relative_path "metasploit-framework-4.11.1"

build do
	bundle "install"
end
