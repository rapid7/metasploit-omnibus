name "jemalloc"

default_version "5.2.1"

license_file "COPYING"

skip_transitive_dependency_licensing true

version "5.2.1" do
  source sha256: "34330e5ce276099e2e8950d9335db5a875689a4c6a56751ef3b1d8c537f887f6"
end

source url: "https://github.com/jemalloc/jemalloc/releases/download/#{version}/jemalloc-#{version}.tar.bz2"

relative_path "jemalloc-#{version}"

env = with_standard_compiler_flags(with_embedded_path)

build do
  configure_commands = [
    "--prefix=#{install_dir}/embedded",
    "--with-jemalloc-prefix="
  ]

  configure(*configure_commands, env: env)
  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env
end
