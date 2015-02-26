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
  cmd = ["./configure",
         "--prefix=#{install_dir}/embedded",
         "--disable-readline"
         ].join(" ")
  env = {
    "LDFLAGS" => "-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include",
    "CFLAGS" => "-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include",
    "LD_RUN_PATH" => "#{install_dir}/embedded/lib"
  }
  command cmd, :env => env
  #command "make -j #{max_build_jobs}", :env => {"LD_RUN_PATH" => "#{install_dir}/embedded/lib"}
  #command "make install", :env => {"LD_RUN_PATH" => "#{install_dir}/embedded/lib"}end
  make "-j #{workers}", env: env
  make "install", env: env
end


