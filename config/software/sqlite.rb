#
# Copyright:: Copyright (c) 2012 Opscode, Inc.
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

name "sqlite"
default_version "3.8.8.2"

source :url => "https://sqlite.org/2015/sqlite-autoconf-3080802.tar.gz",
       :md5 => "3425fa580a56880f56bcb887dd26cc06"

relative_path "sqlite-autoconf-3080802"

build do
  use_bash = ""
  env = {
    "LDFLAGS" => "-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include",
    "CFLAGS" => "-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include",
    "LD_RUN_PATH" => "#{install_dir}/embedded/lib"
  }
  if windows?
    use_bash = "#{install_dir}/embedded/msys64/usr/bin/bash.exe -lc " # in windows we do not use ./ for location
    env['MSYSTEM'] = windows_arch_i386? ? 'MINGW32' : 'MINGW64'
  end
  cmd = ["#{use_bash}./configure",
         "--prefix=#{install_dir}/embedded",
         "--disable-readline"
         ].join(" ")
  command cmd, :env => env
  make "-j #{workers}", env: env
  make "install prefix=#{install_dir}/embedded", env: env
end


