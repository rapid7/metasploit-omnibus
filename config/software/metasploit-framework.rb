name "metasploit-framework"
default_version "master"
#source git: "https://github.com/rapid7/metasploit-framework.git"

default_version "4.11.1"
source url: "https://github.com/rapid7/metasploit-framework/archive/#{default_version}.tar.gz",
       md5: "8194917a8b5e53f9f72e8ba55df8c8cf"
relative_path "metasploit-framework-#{default_version}"

dependency "bundler"
dependency "liblzma"
dependency "libpcap"
dependency "ruby"
dependency "postgresql"
dependency "sqlite"

whitelist_file "#{install_dir}//framework/data/isight.bundle"

build do
	command "mkdir #{install_dir}/bin"

	metasploit_bins = [
	      'msfbinscan',
	      'msfcli',
	      'msfconsole',
	      'msfd',
	      'msfelfscan',
	      'msfencode',
	      'msfmachscan',
	      'msfpayload',
	      'msfpescan',
	      'msfrop',
	      'msfrpc',
	      'msfrpcd',
	      'msfupdate',
	      'msfvenom'
	]

	metasploit_bins.each { |bin|
		command "cat << EOF > #{install_dir}/bin/#{bin}
cd #{install_dir}/framework
#{install_dir}/embedded/bin/bundle exec \
#{install_dir}/embedded/bin/ruby \
#{install_dir}/framework/#{bin}
cd -
EOF"
		command "chmod +x #{install_dir}/bin/#{bin}"
	}

	copy "#{project_dir}", "#{install_dir}/framework"

	bundle "install"
end
