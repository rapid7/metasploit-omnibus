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

name "ruby-windows-msys2"
default_version "20180531"

license "BSD-3-Clause"
license_file "https://raw.githubusercontent.com/Alexpux/MSYS2-packages/master/LICENSE"
skip_transitive_dependency_licensing true

if windows_arch_i386?
  version "20180531" do
    source url: "http://repo.msys2.org/distrib/i686/msys2-base-i686-#{version}.tar.gz",
           md5: "08bbc0437919d64da28801ec54e3d943"
    relative_path "msys32"
  end
else
  version "20180531" do
    source url: "http://repo.msys2.org/distrib/x86_64/msys2-base-x86_64-#{version}.tar.gz",
           md5: "f7ff799d6bb4dcc68c810a6f20d12002"
    relative_path "msys64"
  end
end

build do
  env = with_standard_compiler_flags(with_embedded_path)

  msys_dir = "#{install_dir}/embedded/#{relative_path}"

  sync "#{project_dir}/", "#{msys_dir}"

  command "#{msys_dir}/msys2_shell.cmd -c", env: env
  command "#{msys_dir}/usr/bin/bash.exe -lc 'pacman --noconfirm -Syuu'", env: env
  command "#{msys_dir}/usr/bin/bash.exe -lc 'pacman --noconfirm -Syuu'", env: env
  command "#{msys_dir}/usr/bin/bash.exe -lc 'pacman --noconfirm -Syuu'", env: env
  command "#{msys_dir}/usr/bin/bash.exe -lc 'pacman --noconfirm -Syuu'", env: env
end
