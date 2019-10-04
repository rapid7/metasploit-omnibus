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

name "winpcap-devpack"
default_version "4.1.2"

version "4.1.2" do
  source md5: "bae2236af062b0900ad1416b2c4878b9"
end

dependency "ruby-windows"
dependency "ruby-windows-devkit"

relative_path "WpdPack"

source url: "https://www.winpcap.org/install/bin/WpdPack_4_1_2.zip"

build do

  mkdir "#{install_dir}/embedded/lib"
  if windows_arch_i386?
    copy "#{project_dir}/Lib/*", "#{install_dir}/embedded/lib"
  else
    copy "#{project_dir}/Lib/x64/*", "#{install_dir}/embedded/lib"
  end
  mkdir "#{install_dir}/embedded/include/ruby-2.6.0"
  copy "#{project_dir}/Include/*", "#{install_dir}/embedded/include/ruby-2.6.0"

end
