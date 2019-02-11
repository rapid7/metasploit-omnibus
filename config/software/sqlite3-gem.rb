name "sqlite3-gem"
default_version "1.3.11"

gem_config = ""

if windows?
  dependency "sqlite"
  dependency "ruby-windows"
  dependency "ruby-windows-devkit"
  dependency "bundler"
  gem_config = "--platform=ruby -- --with-sqlite3-include=#{install_dir}/embedded/include --with-sqlite3-lib=#{install_dir}/embedded/lib"
else
  dependency "ruby"
  dependency "libpcap"
end

dependency "rubygems"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  gem "install sqlite3" \
    " -v#{version} #{gem_config}", env: env
end
