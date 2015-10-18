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
default_version "2.2.4"

source url: "http://ftp5.usa.openbsd.org/pub/OpenBSD/LibreSSL/libressl-#{version}.tar.gz",
       sha256: '6b409859be8654afc3862549494e097017e64c8d167f12584383586306ef9a7e'

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
