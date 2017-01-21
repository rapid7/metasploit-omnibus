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

name "postgresql-windows-prev"
default_version "9.4.5"

version "9.4.5" do
  source sha256: "6d2163611b6b159246896898dd1ee23cf29972c9a0449a8aac9c126cfc88a87f"
end

relative_path "pgsql"

source url: "http://get.enterprisedb.com/postgresql/postgresql-#{version}-1-windows-binaries.zip"

build do

  mkdir "#{install_dir}/embedded/postgresql-prev/bin"
  copy "#{project_dir}/bin/*", "#{install_dir}/embedded/postgresql-prev/bin"
  mkdir "#{install_dir}/embedded/postgresql-prev/lib"
  copy "#{project_dir}/lib/*", "#{install_dir}/embedded/postgresql-prev/lib"
  mkdir "#{install_dir}/embedded/postgresql-prev/share"
  copy "#{project_dir}/share/*", "#{install_dir}/embedded/postgresql-prev/share"

end
