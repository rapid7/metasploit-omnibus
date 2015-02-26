#
# Copyright:: Copyright (c) 2014 Opscode, Inc.
# License:: Apache License, Version 2.0
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

name "ruby-windows-devkit-bash"
default_version "3.1.23-4-msys-1.0.18"

dependency "ruby-windows-devkit"
source url: "https://github.com/opscode/msys-bash/releases/download/bash-#{version}/bash-#{version}-bin.tar.lzma",
       md5: "22d5dbbd9bd0b3e0380d7a0e79c3108e"

build do
  temp_directory = File.join(Omnibus::Config.cache_dir, "bash-cache")
  mkdir temp_directory
  # First extract the tar file out of lzma archive.
  command "7z.exe x #{project_file} -o#{temp_directory} -r -y"
  # Now extract the files out of tar archive.
  command "7z.exe x #{File.join(temp_directory, "bash-#{version}-bin.tar")} -o#{temp_directory} -r -y"
  # Copy over the required bins into embedded/bin
  ["bash.exe", "sh.exe"].each do |exe|
    copy "#{temp_directory}/bin/#{exe}", "#{install_dir}/embedded/bin/#{exe}"
  end
end
