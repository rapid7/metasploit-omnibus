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
default_version "2.6.1-1"

if windows_arch_i386?
  relative_path "rubyinstaller-#{version}-x86"

  version "2.4.3-2" do
    source sha256: "ffd023d0aea50c3a9d7a4719c322aa46c4de54fdef55756264663ca74a7c13ea"
  end
  version "2.5.3-1" do
    source sha256: "dc24e05c2c1490c74c6a7256c015cb786fb5f1898f2d8c92cbe4ca8fa271f24a"
  end

  source url: "https://github.com/oneclick/rubyinstaller2/releases/download/rubyinstaller-#{version}/rubyinstaller-#{version}-x86.7z"
else
  relative_path "rubyinstaller-#{version}-x64"

  version "2.4.3-2" do
    source sha256: "3c9ace4e96a1bc7bca2c260bf35230e17662857e20a9637bade901cf55622661"
  end
  version "2.5.3-1" do
    source sha256: "eabd682a6fb886a22168f568b9c508318f045dc2e130b2668e39c4a81d340ec9"
  end
  version "2.6.1-1" do
    source sha256: "53e720d866337d9289c457e97bfdb44fc70ed7e42a3dcb8dbb43f7e93147614d"
  end

  source url: "https://github.com/oneclick/rubyinstaller2/releases/download/rubyinstaller-#{version}/rubyinstaller-#{version}-x64.7z"
end

build do
  sync "#{project_dir}/", "#{install_dir}/embedded"
end
