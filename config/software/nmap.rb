name "nmap"
default_version "6.47"

version("6.47") { source md5: "edfe81f6763223c0a29bfa15a8526e2a" }

source url: "https://nmap.org/dist/nmap-6.47.tar.bz2"

relative_path "nmap-#{version}"

dependency "openssl"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  command "./configure --prefix=#{install_dir}/embedded", env: env
  make env: env
  make "install", env: env
end
