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
default_version "1.1.34"

license "MIT"
license_file "COPYING"
skip_transitive_dependency_licensing true

dependency "libxml2"
dependency "liblzma"
dependency "config_guess"

# versions_list: ftp://xmlsoft.org/libxml2/ filter=*.tar.gz
version("1.1.34") { source sha256: "98b1bd46d6792925ad2dfe9a87452ea2adebf69dcb9919ffd55bf926a7f93f7f" }
version("1.1.30") { source sha256: "ba65236116de8326d83378b2bd929879fa185195bc530b9d1aba72107910b6b3" }

source url: "ftp://xmlsoft.org/libxml2/libxslt-#{version}.tar.gz"

relative_path "libxslt-#{version}"

build do
  update_config_guess

  env = with_standard_compiler_flags(with_embedded_path)

  patch source: "libxslt-solaris-configure.patch", env: env if solaris2? || omnios? || smartos?

  if windows?
    patch source: "libxslt-windows-relocate.patch", env: env
  end

  # the libxslt configure script iterates directories specified in
  # --with-libxml-prefix looking for the libxml2 config script. That
  # iteration treats colons as a delimiter so we are using a cygwin
  # style path to accomodate
  configure_commands = [
    "--with-libxml-prefix=#{install_dir.sub("C:", "/C")}/embedded",
    "--without-python",
    "--without-crypto",
    "--without-profiler",
    "--without-debugger",
  ]

  configure(*configure_commands, env: env)

  make "-j #{workers}", env: env
  make "install", env: env
end
