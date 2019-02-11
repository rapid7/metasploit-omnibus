name "metasploit-framework-wrappers-windows"

default_version "1.0.0"

dependency "metasploit-framework"

build do
  mkdir "#{install_dir}/bin"

  erb source: 'msfdb.bat.erb',
      dest: "#{install_dir}/bin/msfdb.bat",
      mode: 0755,
      vars: { install_dir: install_dir }

  erb source: 'msfremove.ps1.erb',
      dest: "#{install_dir}/bin/msfremove.ps1",
      mode: 0755,
      vars: { install_dir: install_dir }

  erb source: 'msfremove.bat.erb',
      dest: "#{install_dir}/bin/msfremove.bat",
      mode: 0755,
      vars: { install_dir: install_dir }

  erb source: 'msfupdate.ps1.erb',
      dest: "#{install_dir}/bin/msfupdate.ps1",
      mode: 0755,
      vars: { install_dir: install_dir }

  erb source: 'msfupdate.bat.erb',
      dest: "#{install_dir}/bin/msfupdate.bat",
      mode: 0755,
      vars: { install_dir: install_dir }

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
    erb source: 'msfwrapper.bat.erb',
        dest: "#{install_dir}/bin/#{bin}.bat",
        mode: 0755,
        vars: { install_dir: install_dir }
  }
end
