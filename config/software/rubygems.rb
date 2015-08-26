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

name "rubygems"
default_version "2.4.5"

if windows?
  dependency "ruby-windows"
  dependency "ruby-windows-devkit"
else
  dependency "ruby"
end

source git: 'https://github.com/rubygems/rubygems.git'

# NOTE: Originally we always installed rubygems from tarballs, but now we want
# to default to pulling from git. Rubygems uses the leading "v" in their
# version tags, e.g., v2.4.4 (instead of just 2.4.4). There are a lot of
# omnibus projects using this, and we don't want to force everyone to change
# their version pins to include the leading "v", so we need to set the source
# URL on a per-version basis.
tarball_url = "http://production.cf.rubygems.org/rubygems/rubygems-#{version}.tgz"

version "1.8.29" do
  source md5: "a57fec0af33e2e2e1dbb3a68f6cc7269", url: tarball_url
  source.delete(:git)
end

version "1.8.24" do
  source md5: "3a555b9d579f6a1a1e110628f5110c6b", url: tarball_url
  source.delete(:git)
end

# NOTE: this is the last version of rubygems before the 2.2.x change to native gem install location
#
#  https://github.com/rubygems/rubygems/issues/874
#
# This is a breaking change for omnibus clients.  Chef-11 needs to be pinned to 2.1.11 for eternity.
version "2.1.11" do
  source md5: "b561b7aaa70d387e230688066e46e448", url: tarball_url
  source.delete(:git)
end

version "2.2.1" do
  source md5: "1f0017af0ad3d3ed52665132f80e7443", url: tarball_url
  source.delete(:git)
end

version "2.4.1" do
  source md5: "7e39c31806bbf9268296d03bd97ce718", url: tarball_url
  source.delete(:git)
end

version "2.4.4" do
  source md5: "440a89ad6a3b1b7a69b034233cc4658e", url: tarball_url
  source.delete(:git)
end

version "2.4.5" do
  source md5: "5918319a439c33ac75fbbad7fd60749d", url: tarball_url
  source.delete(:git)
end

version "v2.4.4_plus_debug" do
  source git: 'git@github.com:danielsdeleo/rubygems.git'
end

version "2.4.4.debug.1" do
  source git: 'git@github.com:danielsdeleo/rubygems.git'
end

# tarballs get expanded as rubygems-xyz, git repo is always rubygems:
if source.key?(:url)
  relative_path "rubygems-#{version}"
else
  relative_path "rubygems"
end


build do
  env = with_embedded_path

  ruby "setup.rb --no-ri --no-rdoc", env: env

  if windows?
    # After installing ruby, we need to rerun the command that patches devkit
    # functionality into rubygems.
    embedded_dir = "#{install_dir}/devkit"
    ruby "dk.rb install", env: env, cwd: embedded_dir
  end
end
