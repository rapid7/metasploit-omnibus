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
default_version "3.0.2-1"

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
    source sha256: "3f637d73092d3004fb1cee2d7047949aad3880042879d8de55bf661a399f06fc"
  end
  version "2.6.5-1" do
    source sha256: "9b1866e59fe1e7336c4e3231823ff24e121878ed1bac8194ad3fe5e9f2f9ef69"
  end
  version "2.6.6-1" do
    source sha256: "fe5ca2e3ceffa1a98051a85b4028a2bb57332ad4dbb439e377c5775e463096e3"
  end
  version "2.7.2-1" do
    source sha256: "925cc01d453951d1d0c077c44cec90849afc8d23e45946e19ecd3aaabc0c0ab3"
  end

  version "3.0.2-1" do
    source sha256: "92894c0488ec7eab02b2ffc61a8945c4bf98d69561e170927ec30d60bee57898"
  end

  source url: "https://github.com/oneclick/rubyinstaller2/releases/download/rubyinstaller-#{version}/rubyinstaller-#{version}-x64.7z"
end

build do
  sync "#{project_dir}/", "#{install_dir}/embedded"
end

