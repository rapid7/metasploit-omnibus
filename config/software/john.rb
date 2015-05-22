name "john"
default_version "1.8.0"

version("1.8.0") { source md5: "a4086df68f51778782777e60407f1869" }

source url: "http://www.openwall.com/john/j/john-1.8.0.tar.xz"

relative_path "john-#{version}/src"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  make env: env
  make "clean generic", env: env
  command "chmod +r #{project_dir}/../run/john.conf"
  copy "#{project_dir}/../run/*", "#{install_dir}/embedded/bin/"
end
