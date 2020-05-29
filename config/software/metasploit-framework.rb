name "metasploit-framework"
if linux? && File.exist?("/metasploit-framework")
  # supply current version of metasploit-framework at root of filesystem
  source path: "/metasploit-framework"
else
  source git: "https://github.com/rapid7/metasploit-framework.git"
  default_version "master"
end

dependency "bundler"
dependency "pcaprub"
if windows?
  dependency "postgresql-windows"
  dependency "pg"
  dependency "sqlite3-gem"
  sqlite3_gem_version = "-v 1.3.13"
else
  dependency "liblzma"
  dependency "libxslt"
  dependency "ruby"
  dependency "postgresql"
  dependency "sqlite"
end

# This depends on extra system libraries on OS X
whitelist_file "#{install_dir}//embedded/framework/data/isight.bundle"

# Files in this path are currently attached to exploits and required `bad` binaries
whitelist_file "#{install_dir}//embedded/framework/data/exploits/.*"

# This depends on libfuse
whitelist_file "#{install_dir}/embedded/framework/data/exploits/CVE-2016-4557/hello"

# This depends on Openssl 1.x
whitelist_file "#{install_dir}/embedded/lib/ruby/gems/2.3.0/gems/metasploit-payloads.*"

build do
  copy "#{project_dir}", "#{install_dir}/embedded/framework"

  major, minor, patch = Omnibus::BuildVersion.semver.split('.')

  erb source: 'version.yml.erb',
      dest: "#{install_dir}/embedded/framework/version.yml",
      mode: 0644,
      vars: {
        major: major,
        minor: minor,
        patch: patch,
        git_hash: `git ls-remote #{source[:git]} HEAD`.strip.split(' ')[0],
        date: Time.new.strftime("%Y%m%d")
      }

  erb source: 'msfdb.erb',
      dest: "#{install_dir}/embedded/framework/msfdb",
      mode: 0755,
      vars: { install_dir: install_dir }

  block "Give precedence to msfdb if found in '#{project_dir}'" do
    if File.exist?("#{project_dir}/msfdb")
      # install msfdb found in metasploit-framework
      FileUtils.cp("#{project_dir}/msfdb", "#{install_dir}/embedded/framework/")
    end
  end

  env = with_standard_compiler_flags(with_embedded_path)
  unless windows?
    erb source: 'msfdb-kali.erb',
        dest: "#{install_dir}/embedded/framework/msfdb-kali",
        mode: 0755,
        vars: { install_dir: install_dir }
  else
    # patch gemspec to override pg version to one with 2.5 native supplied
    # this is only a viable option because pg does not have any other dependencies
    # as some point activerecord updates or impelmentation of bunlder feature
    # requested in https://github.com/bundler/bundler/pull/6247 will allow removal
    # of this hack
    patch source: "bump_pg.patch", plevel: 1, env: env
    # remove after bundle is installed
  end

  bundle "install", env: env

  if windows?
    # Workaround missing Ruby 2.3 support for bcrypt on Windows
    # https://github.com/codahale/bcrypt-ruby/issues/139
    gem "uninstall bcrypt", env: env
    gem "install bcrypt --no-document --platform=ruby -v3.1.12", env: env

    patch source: "reset_pg.patch", plevel: 1, env: env
    gem "uninstall pg -v1.1.4 --force", env: env

    gem "uninstall sqlite3", env: env
    gem "install sqlite3 #{sqlite3_gem_version} --no-document --platform=ruby", env: env

    delete "#{install_dir}/devkit"
  end
  copy "#{project_dir}/Gemfile.lock", "#{install_dir}/embedded/framework/Gemfile.lock"

  # Darwin needs extra tweaks to library files to work relatively.
  #
  # We need to replace all hard coded `/opt/metasploit-framework` load commands in library files, such as:
  #
  #    $ otool -L ./embedded/lib/ruby/gems/2.6.0/gems/eventmachine-1.2.7/lib/rubyeventmachine.bundle
  #    ./embedded/lib/ruby/gems/2.6.0/gems/eventmachine-1.2.7/lib/rubyeventmachine.bundle:
  #      @executable_path/../lib/libruby.2.6.dylib (compatibility version 2.6.0, current version 2.6.6)
  #      /opt/metasploit-framework/embedded/lib/libssl.1.1.dylib (compatibility version 1.1.0, current version 1.1.0)
  #      /opt/metasploit-framework/embedded/lib/libcrypto.1.1.dylib (compatibility version 1.1.0, current version 1.1.0)
  #      /usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 120.1.0)
  #      /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1226.10.1)
  #
  # To instead use a relative path:
  #      @executable_path/../lib/libcrypto.1.1.dylib
  #
  # Full context: https://github.com/rapid7/metasploit-omnibus/pull/127#issuecomment-632842474
  if mac_os_x?
    block do
      build_files = Dir[
        "#{install_dir}/embedded/bin/*",
        "#{install_dir}/embedded/lib/**/*"
      ]
      absolute_lib_path = "#{install_dir}/embedded/lib"

      build_files.each do |file|
        load_commands = %x{ otool -L '#{file}' 2>/dev/null }.lines.map(&:strip)
        load_commands.each do |load_command|
          next unless load_command.start_with?(absolute_lib_path)
          next if load_command.end_with?(':')

          if (match = load_command.match(/^(?<old_path>.*) (?<version_notes>\(.*\))$/))
            old_absolute_path = match[:old_path]
            new_relative_path = old_absolute_path.gsub(/^#{absolute_lib_path}/, "@executable_path/../lib")
            command("install_name_tool -change '#{old_absolute_path}' '#{new_relative_path}' '#{file}'")
          else
            raise "Could not successfully patch load_command for relative dynamic linking for dependency '#{file}'"
          end
        end
      end
    end
  end
end
