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

name "ruby-windows"
default_version "2.4.3-2"

relative_path "rubyinstaller-#{version}-x86"

version "2.4.3-2" do
  source sha256: "ffd023d0aea50c3a9d7a4719c322aa46c4de54fdef55756264663ca74a7c13ea"
end

source url: "https://github.com/oneclick/rubyinstaller2/releases/download/rubyinstaller-#{version}/rubyinstaller-#{version}-x86.7z"

build do
  sync "#{project_dir}/", "#{install_dir}/embedded"
end
