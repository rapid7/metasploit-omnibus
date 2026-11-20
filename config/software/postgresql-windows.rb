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

name "postgresql-windows"
default_version "16.14"

relative_path "pgsql"

if windows_arch_i386?
  raise "32-bit Windows is no longer supported"
else
  version "16.14" do
    source sha256: "f68c7fbd93029e60a4145ccb64337a32ddf02317a8194cb1f76e11557602642c"
  end

  source url: "http://get.enterprisedb.com/postgresql/postgresql-#{version}-1-windows-x64-binaries.zip"
end

build do

  copy "#{project_dir}/bin/*", "#{install_dir}/embedded/bin"
  copy "#{project_dir}/lib/*", "#{install_dir}/embedded/lib"
  # Remove the OpenSSL import libraries bundled by PostgreSQL so MinGW links native
  # extensions against MSYS2's OpenSSL .dll.a rather than PostgreSQL's older .lib
  # (which otherwise take precedence on the library search path at build time).
  delete "#{install_dir}/embedded/lib/libcrypto.lib"
  delete "#{install_dir}/embedded/lib/libssl.lib"
  # The OpenSSL runtime DLLs are intentionally left to coexist rather than being
  # unified onto a single copy:
  # - PostgreSQL 16.x ships libpq linked against OpenSSL 3.0.x -> libcrypto-3-x64.dll / libssl-3-x64.dll
  # - RubyInstaller 3.4.13+ bundles OpenSSL 4.x            -> libcrypto-4-x64.dll / libssl-4-x64.dll
  # The differing sonames mean the files no longer collide in embedded/bin, so each
  # consumer loads its matching major version: libpq uses the -3- DLLs from PostgreSQL,
  # Ruby's openssl.so uses the -4- DLLs from its own x64-mingw-ucrt platform dir.
  # (Unifying them was only possible while both sides were OpenSSL 3; OpenSSL 3 and 4
  # are not ABI compatible, so replacing libpq's -3- DLLs with -4- would break it.)
  # Remove headers that conflict with other omnibus-bundled libraries before copying
  delete "#{project_dir}/include/libxml"
  delete "#{project_dir}/include/libxslt"
  delete "#{project_dir}/include/openssl"
  copy "#{project_dir}/include/*", "#{install_dir}/embedded/include"
  copy "#{project_dir}/share/*", "#{install_dir}/embedded/share"

end
