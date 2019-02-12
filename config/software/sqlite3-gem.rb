# configure the bundler environment to build sqlite3 gem native
name "sqlite3-gem"
default_version ""

if windows?
  dependency "ruby-windows"
  dependency "ruby-windows-devkit"
  dependency "rubygems"
  dependency "bundler"
  gem_config = " --with-sqlite3-include=#{install_dir}/embedded/include --with-sqlite3-lib=#{install_dir}/embedded/lib"


  build do
    env = with_standard_compiler_flags(with_embedded_path)
    msys_dir = "#{install_dir}/embedded/msys64"
    command "#{msys_dir}/usr/bin/bash.exe -lc 'pacman --noconfirm -Syuu mingw-w64-x86_64-sqlite3'", env: env
    bundle "config build.sqlite3" \
      "#{gem_config}", env: env
  end
end
