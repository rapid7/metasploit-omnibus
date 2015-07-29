name "metasploit-framework"
source git: "https://github.com/rapid7/metasploit-framework.git"
default_version "master"

#default_version "release"
#source url: "https://github.com/rapid7/metasploit-framework/archive/#{default_version}.tar.gz",
#       md5: "8194917a8b5e53f9f72e8ba55df8c8cf"
#relative_path "metasploit-framework-#{default_version}"

dependency "bundler"
if windows?
  dependency "postgresql-windows"
else
  dependency "liblzma"
  dependency "libpcap"
  dependency "libxslt"
  dependency "nokogiri"
  dependency "ruby"
  dependency "postgresql"
  dependency "sqlite"
end

# This depends on extra system libraries on OS X
whitelist_file "#{install_dir}//embedded/framework/data/isight.bundle"

# This depends on Openssl 1.x
whitelist_file "#{install_dir}/embedded/framework/data/john/.*"
whitelist_file "#{install_dir}/embedded/lib/ruby/gems/2.1.0/gems/metasploit-payloads.*"

build do
  copy "#{project_dir}", "#{install_dir}/embedded/framework"
  patch source: "no-git.diff", plevel: 1, target: "#{install_dir}/embedded/framework/metasploit-framework.gemspec"

  major, minor, patch = Omnibus::BuildVersion.semver.split('.')

  erb source: 'version.yml.erb',
      dest: "#{install_dir}/embedded/framework/version.yml",
      mode: 0644,
      vars: {
        major: major,
        minor: minor,
        patch: patch,
        git_hash: `git -C #{project_dir} rev-parse HEAD`.strip,
        date: Time.new.strftime("%Y%m%d")
      }

  bundle "install"

  if windows?
    delete "#{install_dir}/devkit"
    delete "#{install_dir}/embedded/share"
    delete "#{install_dir}/embedded/include"
    #command "#{install_dir}/embedded/bin/ruby.exe -e \"File.delete(*Dir.glob('#{install_dir}/framework/data/**/*.dll'))\""
    #command "#{install_dir}/embedded/bin/ruby.exe -e 'Dir.glob(\"#{install_dir}/framework/data/**/*.dll\").each{ |p|  system(\"7z a #{install_dir}/embedded/dll_files.7z #{p}\"); File.delete(p) }'"
  end

  command "chmod o+r #{install_dir}/embedded/lib/ruby/gems/2.1.0/gems/robots-0.10.1/lib/robots.rb"

end
