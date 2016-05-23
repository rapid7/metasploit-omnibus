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

name "libxslt"
default_version "1.1.28"

license "MIT"
license_file "COPYING"

dependency "libxml2"
dependency "liblzma"
dependency "config_guess"
dependency "libtool" if solaris_10?
dependency "patch" if solaris_10?

version "1.1.28" do
  source md5: "9667bf6f9310b957254fdcf6596600b7"
end

version "1.1.26" do
  source md5: "e61d0364a30146aaa3001296f853b2b9"
end

source url: "ftp://xmlsoft.org/libxml2/libxslt-#{version}.tar.gz"

relative_path "libxslt-#{version}"

build do
  update_config_guess

  env = with_standard_compiler_flags(with_embedded_path({}, msys: true), bfd_flags: true)

  patch source: "libxslt-cve-2015-7995.patch", env: env
  patch source: "libxslt-solaris-configure.patch", env: env if solaris?
  patch source: "libxslt-mingw32.patch", env: env if windows?

  configure_commands = [
    "--with-libxml-prefix=#{install_dir}/embedded",
    "--with-libxml-include-prefix=#{install_dir}/embedded/include",
    "--with-libxml-libs-prefix=#{install_dir}/embedded/lib",
    "--without-python",
    "--without-crypto",
  ]

  configure(*configure_commands, env: env)

  if windows?
    # Apply a post configure patch to prevent dll base address clash
    patch source: "libxslt-windows-relocate.patch", env: env if windows?
    make env: env
  else
    make "-j #{workers}", env: env
  end
  make "install", env: env
end
