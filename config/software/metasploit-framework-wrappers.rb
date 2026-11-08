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

  if mac_os_x?
    erb source: 'retire-package-gems.rb.erb',
        dest: "#{install_dir}/embedded/bin/retire-package-gems.rb",
        mode: 0644

    # Record the new payload's registrations before an upgrade can overlay it
    # on an installation containing additional gems.
    block do
      require 'json'
      specifications = Dir.glob("#{install_dir}/embedded/lib/ruby/gems/*/specifications{,/default}/*.gemspec")
      File.write("#{install_dir}/embedded/package-gem-specifications.json",
                 JSON.generate(specifications.map { |path| path.delete_prefix("#{install_dir}/") }.sort))
    end
  end
end
