name "nmap"
default_version "7.12"

version("7.12") { source sha256: "63df082a87c95a189865d37304357405160fc6333addcf5b84204c95e0539b04" }

source url: "https://nmap.org/dist/nmap-7.12.tar.bz2"

relative_path "nmap-#{version}"

dependency "openssl"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  command "./configure --prefix=#{install_dir}/embedded", env: env
  make env: env
  make "install", env: env
end
