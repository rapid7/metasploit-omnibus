name "metasploit-framework"
source git: "https://github.com/rapid7/metasploit-framework.git"
default_version "master"

#default_version "release"
#source url: "https://github.com/rapid7/metasploit-framework/archive/#{default_version}.tar.gz",
#       md5: "8194917a8b5e53f9f72e8ba55df8c8cf"
#relative_path "metasploit-framework-#{default_version}"

dependency "bundler"
dependency "liblzma"
dependency "libpcap"
dependency "libxslt"
dependency "nokogiri"
dependency "ruby"
dependency "postgresql"
dependency "sqlite"
dependency "nmap"
dependency "john"

# This depends on extra system libraries on OS X
whitelist_file "#{install_dir}//embedded/framework/data/isight.bundle"

# This depends on Openssl 1.x
whitelist_file "#{install_dir}/embedded/framework/data/john/.*"
whitelist_file "#{install_dir}/embedded/lib/ruby/gems/2.1.0/gems/metasploit-payloads.*"

build do

  copy "#{project_dir}", "#{install_dir}/embedded/framework"
  patch source: "no-git.diff", plevel: 1, target: "#{install_dir}/embedded/framework/metasploit-framework.gemspec"
  mkdir "#{install_dir}/bin"
  erb source: 'msfdb.erb',
      dest: "#{install_dir}/bin/msfdb",
      mode: 0755,
      vars: { install_dir: install_dir }
  erb source: 'msfwrapper.erb',
      dest: "#{install_dir}/bin/msfwrapper",
      mode: 0755,
      vars: { install_dir: install_dir }

  command "chmod +x #{install_dir}/bin/*"

  metasploit_bins = [
        'msfbinscan',
        'msfconsole',
        'msfd',
        'msfelfscan',
        'msfmachscan',
        'msfpescan',
        'msfrop',
        'msfrpc',
        'msfrpcd',
        'msfupdate',
        'msfvenom'
  ]

  metasploit_bins.each { |bin|
    link "#{install_dir}/bin/msfwrapper", "#{install_dir}/bin/#{bin}"
  }
  link "#{install_dir}/bin/nmap", "#{install_dir}/embedded/bin/nmap"

  bundle "install"
  command "chmod o+r #{install_dir}/embedded/lib/ruby/gems/2.1.0/gems/robots-0.10.1/lib/robots.rb"
end
