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

name "ruby-windows-devkit"
default_version "4.5.2-20111229-1559"

dependency "ruby-windows"

version "4.5.2-20111229-1559" do
  source url: "http://cloud.github.com/downloads/oneclick/rubyinstaller/DevKit-tdm-32-#{version}-sfx.exe",
         md5: "4bf8f2dd1d582c8733a67027583e19a6"
end

version "4.7.2-20130224-1151" do
  source url: "http://cdn.rubyinstaller.org/archives/devkits/DevKit-mingw64-32-#{version}-sfx.exe",
         md5: "9383f12958aafc425923e322460a84de"
end

build do
  env = with_standard_compiler_flags(with_embedded_path)

  embedded_dir = "#{install_dir}/embedded"

  version "4.5.2-20111229-1559" do
    command "DevKit-tdm-32-#{version}-sfx.exe -y -o#{windows_safe_path(embedded_dir)}", env: env
  end

  version "4.7.2-20130224-1151" do
    command "DevKit-mingw64-32-#{version}-sfx.exe -y -o#{windows_safe_path(embedded_dir)}", env: env
  end

  command "echo - #{install_dir}/embedded > config.yml", cwd: embedded_dir
  ruby "dk.rb install", env: env, cwd: embedded_dir

  # may gems that ship with native extensions assume tar will be available in the PATH
  copy "#{install_dir}/embedded/mingw/bin/bsdtar.exe", "#{install_dir}/embedded/mingw/bin/tar.exe"
end
