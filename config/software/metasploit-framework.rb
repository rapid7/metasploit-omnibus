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
end
