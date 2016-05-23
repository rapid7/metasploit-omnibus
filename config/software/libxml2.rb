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

name "libxml2"
default_version "2.9.3"

license "MIT"
license_file "COPYING"

dependency "zlib"
dependency "libiconv"
dependency "liblzma"
dependency "config_guess"

version "2.9.3" do
  source md5: "daece17e045f1c107610e137ab50c179"
end

source url: "ftp://xmlsoft.org/libxml2/libxml2-#{version}.tar.gz"

relative_path "libxml2-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path({}, msys: true), bfd_flags: true)

  configure_command = [
    "--with-zlib=#{install_dir}/embedded",
    "--with-iconv=#{install_dir}/embedded",
    "--without-python",
    "--without-icu",
  ]

  # solaris 10 ipv6 support is broken due to no inet_ntop() in -lnsl
  configure_command << "--enable-ipv6=no" if solaris_10?

  update_config_guess

  configure(*configure_command, env: env)

  if windows?
    make env: env
  else
    make "-j #{workers}", env: env
  end
  make "install", env: env
end
