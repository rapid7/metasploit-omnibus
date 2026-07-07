name "metasploit-framework"

# Detect a local checkout of metasploit-framework at '../metasploit-framework' - i.e. for the scenario of:
# - c:/temp/metasploit-omnibus
# - c:/temp/metasploit-framework (A local checkout of framework to use during the build process)
# but try and use 'C:/metasploit-framework' - as that's the metasploit-omnibus artifacts output directory
def has_windows_metasploit_framework_repo?
  windows? && File.exist?('../metasploit-framework') && File.expand_path(File.join(Dir.pwd, "..", "metasploit-framework")) != "c:/metasploit-framework"
end

if linux? && File.exist?("/metasploit-framework")
  # supply current version of metasploit-framework at root of filesystem
  source path: "/metasploit-framework"
elsif has_windows_metasploit_framework_repo?
  # supply current version of metasploit-framework relative to the current directory
  source path: "../metasploit-framework"
else
  source git: "https://github.com/rapid7/metasploit-framework.git"
  default_version "master"
end

dependency "cacerts"
dependency "bundler"
dependency "pcaprub"
if windows?
  dependency "postgresql-windows"
else
  dependency "liblzma"
  dependency "libxslt"
  dependency "ruby"
  dependency "postgresql"
end

ruby_abi_version = "3.4.0"
# This depends on extra system libraries on OS X
whitelist_file "#{install_dir}//embedded/framework/data/isight.bundle"

# Files in this path are currently attached to exploits and do not need to pass system-specific omnibus health checks
whitelist_file "#{install_dir}/embedded/framework/data/exploits/.*"
whitelist_file "#{install_dir}//embedded/framework/data/exploits/.*"

# This depends on Openssl 3.x
whitelist_file "#{install_dir}/embedded/lib/ruby/gems/#{ruby_abi_version}/gems/metasploit-payloads.*"

# Also whitelist mettle
whitelist_file "#{install_dir}//embedded/lib/ruby/gems/#{ruby_abi_version}/gems/metasploit_payloads.*"

# Also whitelist sqlite deps too as libz is provided just not first on path
whitelist_file "#{install_dir}/embedded/lib/ruby/gems/#{ruby_abi_version}/gems/sqlite3-.*"
whitelist_file "#{install_dir}//embedded/lib/ruby/gems/#{ruby_abi_version}/.*/sqlite3.*"

build do
  patch_env = with_standard_compiler_flags(with_embedded_path)
  block 'Patch Gem dependencies' do
    # Skipping gem dependencies
    ['metasploit-framework.gemspec', 'Gemfile', 'Gemfile.lock'].each do |gemfile|
      # Remove problematic linux dependencies that require newer GCC versions that aren't currently supported on CI build envs
      skipped_dependencies = [
        'ruby-prof',
        'memory_profiler',
        'license_finder',
      ]
      replacements = {
        'stringio (= 3.1.1)' => 'stringio (= 3.1.2)',
        'stringio (3.1.1)' => 'stringio (3.1.2)',
        "spec.add_runtime_dependency 'stringio', '3.1.1'" => "spec.add_runtime_dependency 'stringio', '3.1.2'"
      }
      # Remove problematic dependencies for Windows; Fiddle will need to be re-added in a future build for Ruby 3.3 support
      if windows?
        skipped_dependencies += [
          'ffi (< 1.17.0)',
          'ffi (1.16.3)',
          "spec.add_runtime_dependency 'ffi', '< 1.17.0'",
          'fiddle',
          'packetfu',
          'pcaprub'
        ]
      end

      file_path = File.join(project_dir, gemfile)
      old_file = File.binread(file_path)
      lines = old_file.lines(chomp: true)

      # For Gemfile.lock, we need to remove entire source blocks (GIT/PATH) that
      # contain skipped gems, and individual lines from other sections
      if gemfile == 'Gemfile.lock'
        blocks = old_file.split(/\r?\n\r?\n/)
        new_content = blocks.filter_map do |block|
          if block.start_with?('GIT', 'PATH')
            # Drop entire source block if it contains a skipped gem
            next nil if skipped_dependencies.any? { |dep| block.include?(dep) }
            block
          else
            # Line-level filtering for DEPENDENCIES, GEM specs, etc.
            filtered = block.lines(chomp: true).reject do |line|
              skipped_dependencies.any? { |dep| line.include?(dep) }
            end.join("\n")
            filtered.empty? ? nil : filtered
          end
        end.join("\n\n")
      else
        new_content = lines.reject do |line|
          skipped_dependencies.any? { |dep| line.include?(dep) }
        end.join("\n")
      end
      replacements.each { |old, new| new_content = new_content.gsub(old, new) }

      File.open(file_path, 'wb') { |f| f.puts(new_content) }
    end
  end
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

  bundle "version", env: env
  bundle "config set force_ruby_platform true", env: env
  bundle_env = with_standard_compiler_flags(with_embedded_path)
  bundle_env['MAKE'] = 'make -j4'
  bundle_env['BUNDLE_FORCE_RUBY_PLATFORM'] = 'true'
  bundle "install --jobs=4 --verbose", env: bundle_env

  if windows?
    # Copy required runtime DLLs from MSYS2 ucrt64 to embedded/bin.
    # Native gems (nokogiri, eventmachine, etc.) link against MSYS2's ucrt64
    # libraries during bundle install. These DLLs must be available at runtime.
    # We copy them to embedded/bin (which is in PATH) before deleting msys64.
    msys_ucrt64_bin = "#{install_dir}/embedded/msys64/ucrt64/bin"
    block "Copy MSYS2 runtime DLLs to embedded/bin" do
      required_dlls = %w[
        libxml2-2.dll
        libiconv-2.dll
        liblzma-5.dll
        zlib1.dll
        libintl-8.dll
      ]
      missing = []
      required_dlls.each do |dll|
        src = File.join(msys_ucrt64_bin, dll)
        if File.exist?(src)
          FileUtils.cp(src, "#{install_dir}/embedded/bin/#{dll}")
        else
          missing << src
        end
      end
      raise "MSYS2 runtime DLLs not found:\n  #{missing.join("\n  ")}" if missing.any?
    end

    # Patch the pg gem's postgresql_lib_path.rb to disable add_dll_directory.
    # The pg gem bakes in the compile-time absolute path to libpq which may not
    # exist at runtime if the MSI installs to a different drive. Setting the path
    # to false makes pg skip add_dll_directory and rely on the system PATH instead,
    # where libpq.dll is available via embedded/bin.
    block "Patch pg gem DLL path" do
      pg_lib_path_file = Dir.glob("#{install_dir}/embedded/lib/ruby/gems/*/gems/pg-*/lib/pg/postgresql_lib_path.rb").first
      if pg_lib_path_file
        File.write(pg_lib_path_file, "module PG; POSTGRESQL_LIB_PATH = false; end\n")
      end
    end

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

  # Workaround for a Windows bug with chef r7_9.0.23_custom that allows the `.git` folders through
  # into the final build result, leading to the .exe being an extra 1gb in size
  block do
    self.project.exclusions.each do |exclusion|
      Pathname(install_dir).glob(exclusion).each(&:rmtree)
    end
  end
end
