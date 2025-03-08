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
default_version "20250221"

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
  version "20200903" do
    # file has to be decompressed from local cache using xz before build executes
    source url: "https://repo.msys2.org/distrib/x86_64/msys2-base-x86_64-#{version}.tar",
           sha256: "4507c02cf6c6e4f3de236a89b33e386a396b28ca1c57ad499740d1a7679685d8"
    relative_path "msys64"
  end
  version "20210604" do
    # file has to be decompressed from local cache using xz before build executes
    source url: "https://repo.msys2.org/distrib/x86_64/msys2-base-x86_64-#{version}.tar",
           sha256: "8738e8f0d3e096a8bf581f9ceb674afdcc2fe3202dd1d69f39d9b8d7e3a5e099"
    relative_path "msys64"
  end
  version "20220118" do
    # file has to be decompressed from local cache using xz before build executes
    source url: "https://repo.msys2.org/distrib/x86_64/msys2-base-x86_64-#{version}.tar",
           sha256: "f4f428797a285d29225aebd535d83a4f530fdc3870d8b0a8afa784532472e19d"
    relative_path "msys64"
  end
  version "20220603" do
    # file has to be decompressed from local cache using xz before build executes
    source url: "https://repo.msys2.org/distrib/x86_64/msys2-base-x86_64-#{version}.tar",
           sha256: "39e476b45b7ca39567afd341146af68ed53b89b09c90d285988367ec5c5ecc11"
    relative_path "msys64"
  end
  version "20250221" do
    # file has to be decompressed from local cache using xz before build executes
    source url: "https://repo.msys2.org/distrib/x86_64/msys2-base-x86_64-#{version}.tar",
           sha256: "cf7bd3ecb4f79eaa58ac794dba3cca15581465b9d92cec59ae4bd99fde74c8a0"
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
