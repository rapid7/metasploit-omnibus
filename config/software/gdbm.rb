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

name "gdbm"
default_version "1.9.1"

source url: "http://ftp.gnu.org/gnu/gdbm/gdbm-1.9.1.tar.gz",
       md5: "59f6e4c4193cb875964ffbe8aa384b58"

relative_path "gdbm-1.9.1"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  if freebsd?
    command "./configure" \
            " --enable-libgdbm-compat" \
            " --with-pic" \
            " --prefix=#{install_dir}/embedded", env: env
  else
    command "./configure" \
            " --enable-libgdbm-compat" \
            " --prefix=#{install_dir}/embedded", env: env
  end

  make "-j #{workers}", env: env
  make "install", env: env
end
