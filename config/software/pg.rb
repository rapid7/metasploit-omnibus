name "pg"
default_version "0.21.0"

pg_config = ""

if windows?
  dependency "ruby-windows"
  dependency "ruby-windows-devkit"
  dependency "winpcap-devpack"
  dependency "postgresql-windows"
  dependency "bundler"
  pg_config = "--platform=ruby -- --with-pg-config=#{install_dir}/embedded/bin/pg_config.exe"
else
  dependency "ruby"
  dependency "libpcap"
end

dependency "rubygems"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  gem "install pg" \
    " -v#{version} --no-document #{pg_config}", env: env
end
