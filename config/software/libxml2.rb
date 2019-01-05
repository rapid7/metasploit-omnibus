#
# Copyright 2012-2018, Chef Software Inc.
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
default_version "2.9.7"

license "MIT"
license_file "COPYING"
skip_transitive_dependency_licensing true

dependency "zlib"
dependency "liblzma"
dependency "config_guess"

version "2.9.7" do
  source sha256: "f63c5e7d30362ed28b38bfa1ac6313f9a80230720b7fb6c80575eeab3ff5900c"
end

version "2.9.5" do
  source sha256: "4031c1ecee9ce7ba4f313e91ef6284164885cdb69937a123f6a83bb6a72dcd38"
end

version "2.9.4" do
  source md5: "ae249165c173b1ff386ee8ad676815f5"
end

version "2.9.3" do
  source md5: "daece17e045f1c107610e137ab50c179"
end

source url: "ftp://xmlsoft.org/libxml2/libxml2-#{version}.tar.gz"

relative_path "libxml2-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  configure_command = [
    "--with-zlib=#{install_dir}/embedded",
    "--without-iconv",
    "--without-python",
    "--without-icu",
  ]

  update_config_guess

  configure(*configure_command, env: env)

  make "-j #{workers}", env: env
  make "install", env: env
end
