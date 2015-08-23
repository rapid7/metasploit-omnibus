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
default_version "9.4.4"

dependency "zlib"
dependency "openssl"
dependency "libedit"
dependency "libuuid" unless mac_os_x?
dependency "ncurses"

version "9.1.9" do
  source md5: "6b5ea53dde48fcd79acfc8c196b83535"
end

version "9.1.15" do
  source md5: "6ac52cf13ecf6b09c7d42928d1219cae"
end

version "9.2.8" do
  source md5: "c5c65a9b45ee53ead0b659be21ca1b97"
end

version "9.2.9" do
  source md5: "38b0937c86d537d5044c599273066cfc"
end

version "9.2.10" do
  source md5: "7b81646e2eaf67598d719353bf6ee936"
end

version "9.3.4" do
  source md5: "d0a41f54c377b2d2fab4a003b0dac762"
end

version "9.3.5" do
  source md5: "5059857c7d7e6ad83b6d55893a121b59"
end

version "9.3.6" do
  source md5: "0212b03f2835fdd33126a2e70996be8e"
end

version "9.4.0" do
  source md5: "8cd6e33e1f8d4d2362c8c08bd0e8802b"
end

version "9.4.1" do
  source md5: "2cf30f50099ff1109d0aa517408f8eff"
end

version "9.4.4" do
  source md5: "1fe952c44ed26d7e6a335cf991a9c1c6"
end

source url: "https://ftp.postgresql.org/pub/source/v#{version}/postgresql-#{version}.tar.bz2"

relative_path "postgresql-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

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
