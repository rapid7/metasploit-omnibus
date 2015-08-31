name "metasploit-framework-wrappers"

default_version "1.0.0"

dependency "metasploit-framework"

build do
  mkdir "#{install_dir}/bin"

  erb source: 'msfdb.erb',
      dest: "#{install_dir}/bin/msfdb",
      mode: 0755,
      vars: { install_dir: install_dir }

  erb source: 'msfupdate.erb',
      dest: "#{install_dir}/bin/msfupdate",
      mode: 0755,
      vars: { install_dir: install_dir }

  erb source: 'msfremove.erb',
      dest: "#{install_dir}/bin/msfremove",
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
        'msfvenom'
  ]

  metasploit_bins.each { |bin|
    erb source: 'msfwrapper.erb',
        dest: "#{install_dir}/bin/#{bin}",
        mode: 0755,
        vars: { install_dir: install_dir }
  }
end
