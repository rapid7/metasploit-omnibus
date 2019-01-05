#
# Copyright 2012-2014 Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

name "postgresql"
default_version "9.6.7"

license "PostgreSQL"
license_file "COPYRIGHT"
skip_transitive_dependency_licensing true

dependency "zlib"
dependency "openssl"
dependency "libedit"
dependency "libuuid" unless mac_os_x?
dependency "ncurses"
dependency "config_guess"

version "9.6.7" do
  source sha256: "2ebe3df3c1d1eab78023bdc3ffa55a154aa84300416b075ef996598d78a624c6"
end

version "9.6.3" do
  source sha256: "1645b3736901f6d854e695a937389e68ff2066ce0cde9d73919d6ab7c995b9c6"
end

version "9.6.2" do
  source sha256: "0187b5184be1c09034e74e44761505e52357248451b0c854dddec6c231fe50c9"
end

version "9.6.1" do
  source sha256: "e5101e0a49141fc12a7018c6dad594694d3a3325f5ab71e93e0e51bd94e51fcd"
end

source url: "https://ftp.postgresql.org/pub/source/v#{version}/postgresql-#{version}.tar.bz2"

relative_path "postgresql-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  update_config_guess(target: "config")

  command "./configure" \
          " --prefix=#{install_dir}/embedded" \
          " --with-libedit-preferred" \
          " --with-openssl" \
          " --with-uuid=e2fs" \
          " --with-includes=#{install_dir}/embedded/include" \
          " --with-libraries=#{install_dir}/embedded/lib", env: env

  make "world -j #{workers}", env: env
  make "install-world", env: env
end
