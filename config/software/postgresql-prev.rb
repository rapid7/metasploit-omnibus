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

name "postgresql-prev"
default_version "9.4.5"

license "PostgreSQL"
license_file "COPYRIGHT"
skip_transitive_dependency_licensing true

dependency "zlib"
dependency "openssl"
dependency "libedit"
dependency "libuuid" unless mac_os_x?
dependency "ncurses"
dependency "config_guess"

version "9.4.5" do
  source sha256: "b87c50c66b6ea42a9712b5f6284794fabad0616e6ae420cf0f10523be6d94a39"
end

source url: "https://ftp.postgresql.org/pub/source/v#{version}/postgresql-#{version}.tar.bz2"

relative_path "postgresql-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  update_config_guess(target: "config")

  command "./configure" \
          " --prefix=#{install_dir}/embedded/postgresql-prev" \
          " --with-libedit-preferred" \
          " --with-openssl" \
          " --with-uuid=e2fs" \
          " --with-includes=#{install_dir}/embedded/postgresql-prev/include" \
          " --with-libraries=#{install_dir}/embedded/postgresql-prev/lib", env: env

  make "world -j #{workers}", env: env
  make "install-world", env: env
end
