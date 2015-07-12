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

name "openssl"
default_version "2.2.1"

source url: "http://ftp5.usa.openbsd.org/pub/OpenBSD/LibreSSL/libressl-#{version}.tar.gz",
       md5: '6605ef36e39110bd3da21ec9cf7d2da5'

relative_path "libressl-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  configure_command = "./configure" \
                      " --prefix=#{install_dir}/embedded" \
                      " --disable-asm"

  command configure_command, env: env

  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env
end
