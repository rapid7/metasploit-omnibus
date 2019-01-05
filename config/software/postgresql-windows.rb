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
default_version "9.6.7"

version "9.6.7" do
  source sha256: "68870e3f686295cce60b50cea92421fa168274790f97c4eb7bf0879c6cb28cd8"
end

version "9.6.2" do
  source sha256: "a4c1f9c4e4938abee245926bbc950a5d01fc3776187044aec2fb1698120f447a"
end

version "9.6.1" do
  source sha256: "16a5b97579587bf6c6ab98788b0c95e55398e87a75b990089522d4837b2da0f4"
end

version "9.4.6" do
  source sha256: "c14025963bf80fac9331f45b314cc508e255048189378e2674f4aaa6fe34e2a7"
end

version "9.4.5" do
  source sha256: "6d2163611b6b159246896898dd1ee23cf29972c9a0449a8aac9c126cfc88a87f"
end

relative_path "pgsql"

source url: "http://get.enterprisedb.com/postgresql/postgresql-#{version}-1-windows-binaries.zip"

build do

  copy "#{project_dir}/bin/*", "#{install_dir}/embedded/bin"
  copy "#{project_dir}/lib/*", "#{install_dir}/embedded/lib"
  copy "#{project_dir}/include/*", "#{install_dir}/embedded/include"
  copy "#{project_dir}/share/*", "#{install_dir}/embedded/share"

end
