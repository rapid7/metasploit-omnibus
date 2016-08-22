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

name "libuuid"
default_version "2.21"

license "LGPL-2.1"
license_file "COPYING"

source url: "https://www.kernel.org/pub/linux/utils/util-linux/v#{version}/util-linux-#{version}.tar.gz"

# We use the version in util-linux, and only build the libuuid subdirectory
version "2.27.1" do
  source md5: "e9c73747eadf5201b2a198530add4f87",
         url: "https://www.kernel.org/pub/linux/utils/util-linux/v2.27/util-linux-2.27.1.tar.gz"
end
version "2.21" do
  source md5: "4222aa8c2a1b78889e959a4722f1881a"
end

relative_path "util-linux-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure --prefix=#{install_dir}/embedded", env: env

  make "-j #{workers}", env: env, cwd: "#{project_dir}/libuuid"
  make "-j #{workers} install", env: env, cwd: "#{project_dir}/libuuid"
end
