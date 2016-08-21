#
# Copyright 2014 Chef Software, Inc.
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

name "util-macros"
default_version "1.19.0"

version "1.19.0" do
  source md5: "40e1caa49a71a26e0aa68ddd00203717"
end

version "1.18.0" do
  source md5: "fd0ba21b3179703c071bbb4c3e5fb0f4"
end

source url: "https://www.x.org/releases/individual/util/util-macros-#{version}.tar.gz"

license "MIT"
license_file "COPYING"
skip_transitive_dependency_licensing true

relative_path "util-macros-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure" \
          " --prefix=#{install_dir}/embedded", env: env

  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env
end
