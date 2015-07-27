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
default_version "9.4.4"

version "9.4.4" do
  source md5: "3f200b6b47f23d499d85dd43b6dd4f04"
end

relative_path "pgsql"

source url: "http://get.enterprisedb.com/postgresql/postgresql-#{version}-3-windows-binaries.zip"

build do

  copy "#{project_dir}/bin/*", "#{install_dir}/embedded/bin"
  copy "#{project_dir}/lib/*", "#{install_dir}/embedded/lib"
  copy "#{project_dir}/include/*", "#{install_dir}/embedded/include"

end
