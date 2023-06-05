name "jemalloc"

default_version "5.3.0"

license_file "COPYING"

skip_transitive_dependency_licensing true

version "5.3.0" do
  source sha256: "2db82d1e7119df3e71b7640219b6dfe84789bc0537983c3b7ac4f7189aecfeaa"
end

source url: "https://github.com/jemalloc/jemalloc/releases/download/#{version}/jemalloc-#{version}.tar.bz2"

relative_path "jemalloc-#{version}"

env = with_standard_compiler_flags(with_embedded_path)

build do
  if rhel?
    patch source: "jemalloc-centos-fix.patch", plevel: 1
  end

  configure_commands = [
    "--prefix=#{install_dir}/embedded",
    "--with-jemalloc-prefix="
  ]

  configure(*configure_commands, env: env)
  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env
end
