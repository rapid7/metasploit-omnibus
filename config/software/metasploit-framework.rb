name "metasploit-framework"
if linux? && File.exist?("/metasploit-framework")
  # supply current version of metasploit-framework at root of filesystem
  source path: "/metasploit-framework"
else
  source git: "https://github.com/rapid7/metasploit-framework.git"
  default_version "master"
end

dependency "cacerts"
dependency "bundler"
dependency "pcaprub"
dependency "sqlite"
if windows?
  dependency "postgresql-windows"
else
  dependency "liblzma"
  dependency "libxslt"
  dependency "ruby"
  dependency "postgresql"
end

ruby_abi_version = "3.0.0"
# This depends on extra system libraries on OS X
whitelist_file "#{install_dir}//embedded/framework/data/isight.bundle"

# Files in this path are currently attached to exploits and required `bad` binaries
whitelist_file "#{install_dir}//embedded/framework/data/exploits/.*"

# This depends on libfuse
whitelist_file "#{install_dir}/embedded/framework/data/exploits/CVE-2016-4557/hello"

# This depends on Openssl 1.x
whitelist_file "#{install_dir}/embedded/lib/ruby/gems/#{ruby_abi_version}/gems/metasploit-payloads.*"

# Also whitelist mettle
whitelist_file "#{install_dir}/embedded/lib/ruby/gems/#{ruby_abi_version}/gems/metasploit_payloads.*"

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
  env['SSL_CERT_FILE'] = "#{install_dir}/embedded/ssl/cert.pem"
  unless windows?
    erb source: 'msfdb-kali.erb',
        dest: "#{install_dir}/embedded/framework/msfdb-kali",
        mode: 0755,
        vars: { install_dir: install_dir }
  end

  if windows?
    sqlite_config = " --with-sqlite3-include=#{install_dir}/embedded/include --with-sqlite3-lib=#{install_dir}/embedded/lib"
    bundle "config set build.sqlite3 #{sqlite_config}", env: env
  end
  bundle "config set force_ruby_platform true", env: env
  bundle "install", env: env

  if windows?
    delete "#{install_dir}/embedded/msys64"
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
  # To instead use relative paths:
  #      @executable_path/../lib/libcrypto.1.1.dylib
  #
  # Full context: https://github.com/rapid7/metasploit-omnibus/pull/127#issuecomment-632842474
  if mac_os_x?
    block do
      absolute_lib_path = "#{install_dir}/embedded/lib"
      relative_lib_path = "@executable_path/../lib"

      macho_files = shellout("find #{project.install_dir}/embedded/{bin,lib} -type f | xargs file | grep Mach-O | awk -F: '{print $1}'").stdout.lines.map(&:strip)
      macho_files.each do |file|
        next if file.end_with?(".a")

        # The first line from otools is the file name. For a valid Mach-O file this will only contain the name:
        #
        #   bin/ruby:
        #      ... load commands...
        #
        # If there's an error, this will be found at the end:
        #
        #   /opt/metasploit-framework/embedded/lib/postgresql/pgxs/config/install-sh: is not an object file
        #
        # Followed by the required load commands
        file_header, *load_commands = shellout("otool -L '#{file}' 2>&1").stdout.lines.map(&:strip)
        # Similar to the output of `-L`, the first line will be the file, followed by the dylib_id
        _file_header, dylib_id = shellout("otool -D '#{file}' 2>&1").stdout.lines.map(&:strip)

        unless file_header.include?(":")
          raise "Expected file header output of otools to contain a ':', but instead found: '#{file_header}'"
        end

        # Handling the LC_ID_DYLIB load command
        unless dylib_id.nil?
          new_relative_id = dylib_id.gsub(/^#{absolute_lib_path}/, relative_lib_path)
          command("install_name_tool -id '#{new_relative_id}' '#{file}'")
        end

        # Handling load commands that import libraries, note that the LC_ID_DYLIB may be part of this list.
        # However, install_name_tool will ignore the `-change` command safely.
        load_commands.each do |load_command|
          next unless load_command.start_with?(absolute_lib_path)

          if (match = load_command.match(/^(?<old_path>.*) (?<version_notes>\(.*\))$/))
            old_absolute_path = match[:old_path]
            new_relative_path = old_absolute_path.gsub(/^#{absolute_lib_path}/, relative_lib_path)
            command("install_name_tool -change '#{old_absolute_path}' '#{new_relative_path}' '#{file}'")
          else
            raise "Could not successfully patch load_command for relative dynamic linking for dependency '#{file}'"
          end
        end
      end
    end
  end
end
