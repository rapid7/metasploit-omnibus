#
# Copyright:: Copyright (c) 2014-2017, Chef Software Inc.
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

license "GPL-3.0"
license_file "http://www.gnu.org/licenses/gpl-3.0.txt"
skip_transitive_dependency_licensing true

# XXX: this depends on ruby-windows-devkit, but the caller MUST specify that dep, or else the slightly goofy
# library build_order optimizer in omnibus will promote ruby-windows-devkit to being before direct deps of
# the project file which will defeat our current strategy of installing devkit absolutely dead last.
# see: https://github.com/chef/omnibus/blob/2f9687fb1a3d2459b932acb4dcb37f4cb6335f4c/lib/omnibus/library.rb#L64-L77
#
# dependency "ruby-windows-devkit"
source url: "https://github.com/chef/msys-bash/releases/download/bash-#{version}/bash-#{version}-bin.tar.lzma",
       md5: "22d5dbbd9bd0b3e0380d7a0e79c3108e"

relative_path "bin"

build do
  # Copy over the required bins into embedded/bin
  ["bash.exe", "sh.exe"].each do |exe|
    copy "#{exe}", "#{install_dir}/embedded/bin/#{exe}"
  end
end
