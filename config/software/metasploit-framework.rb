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
dependency "libxslt"
dependency "ruby"
dependency "postgresql"
dependency "sqlite"

# This depends on extra system libraries on OS X
whitelist_file "#{install_dir}//framework/data/isight.bundle"

# This depends on Openssl 1.x
whitelist_file "#{install_dir}/framework/data/john/run.linux.x64.mmx/john"
whitelist_file "#{install_dir}/framework/data/john/run.linux.x64.mmx/calc_stat"
whitelist_file "#{install_dir}/framework/data/john/run.linux.x64.mmx/genmkvpwd"
whitelist_file "#{install_dir}/framework/data/john/run.linux.x64.mmx/tgtsnarf"
whitelist_file "#{install_dir}/framework/data/john/run.linux.x64.mmx/mkvcalcproba"

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

	move "#{install_dir}/embedded/include/libxml2/libxml", "#{install_dir}/embedded/include/"
	bundle "config build.nokogiri --use-system-libraries --with-xml2-config=#{install_dir}/embedded/bin/xml2-config --with-xslt-config=#{install_dir}/embedded/bin/xslt-config"
	bundle "install"
	command "chmod o+r #{install_dir}/embedded/lib/ruby/gems/2.1.0/gems/robots-0.10.1/lib/robots.rb"
end
