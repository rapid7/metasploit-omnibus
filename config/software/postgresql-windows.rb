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
  copy "#{project_dir}/include/*", "#{install_dir}/embedded/include"
  # Remove headers that conflict with other omnibus-bundled libraries (e.g. nokogiri's libxml2/libxslt)
  delete "#{install_dir}/embedded/include/libxml"
  delete "#{install_dir}/embedded/include/libxslt"
  delete "#{install_dir}/embedded/include/openssl"
  copy "#{project_dir}/share/*", "#{install_dir}/embedded/share"

end
