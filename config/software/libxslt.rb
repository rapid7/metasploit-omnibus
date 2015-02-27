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

name "libxslt"
default_version "1.1.28"

dependency "libxml2"
dependency "libtool" if solaris2?
dependency "liblzma"

version "1.1.26" do
  source md5: "e61d0364a30146aaa3001296f853b2b9"
end

version "1.1.28" do
  source md5: "9667bf6f9310b957254fdcf6596600b7"
end

source url: "ftp://xmlsoft.org/libxml2/libxslt-#{version}.tar.gz"

relative_path "libxslt-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure" \
          " --prefix=#{install_dir}/embedded" \
          " --with-libxml-prefix=#{install_dir}/embedded" \
          " --with-libxml-include-prefix=#{install_dir}/embedded/include" \
          " --with-libxml-libs-prefix=#{install_dir}/embedded/lib" \
          " --without-python" \
          " --without-crypto", env: env

  make "-j #{workers}", env: env
  make "install", env: env
end
