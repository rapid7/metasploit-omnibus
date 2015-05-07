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

name "zlib"
default_version "1.2.8"

version "1.2.6" do
  source md5: "618e944d7c7cd6521551e30b32322f4a"
end

version "1.2.8" do
  source md5: "44d667c142d7cda120332623eab69f40"
end

source url: "http://downloads.sourceforge.net/project/libpng/zlib/#{version}/zlib-#{version}.tar.gz"

relative_path "zlib-#{version}"

build do
  # We omit the omnibus path here because it breaks mac_os_x builds by picking
  # up the embedded libtool instead of the system libtool which the zlib
  # configure script cannot handle.
  env = with_standard_compiler_flags

  if solaris?
    # For some reason zlib needs this flag on solaris (cargocult warning?)
    env['CFLAGS'] << " -DNO_VIZ" if solaris2?
  elsif freebsd?
    # FreeBSD 10+ gets cranky if zlib is not compiled in a
    # position-independent way.
    env['CFLAGS'] << " -fPIC"
  end

  command "./configure" \
          " --prefix=#{install_dir}/embedded", env: env

  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env
end
