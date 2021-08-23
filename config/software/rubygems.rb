#
# Copyright 2012-2016 Chef Software, Inc.
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

license "MIT"
license_file "https://raw.githubusercontent.com/rubygems/rubygems/master/LICENSE.txt"
skip_transitive_dependency_licensing true

if windows?
  dependency "ruby-windows"
  dependency "ruby-windows-devkit"
  dependency "ruby-windows-msys2"
else
  dependency "ruby"
end

default_version "3.2.22"

if version && !source
  # NOTE: 2.1.11 is the last version of rubygems before the 2.2.x change to native gem install location
  #
  #  https://github.com/rubygems/rubygems/issues/874
  #
  # This is a breaking change for omnibus clients.  Chef-11 needs to be pinned to 2.1.11 for eternity.
  # We have switched from tarballs to just `gem update --system`, but for backcompat
  # we pin the previously known tarballs.
  known_tarballs = {
    "3.1.4" => "d117187a8f016cbe8f52011ae02e858b",
    "3.2.22"=> "b128d5493da2ec7a1da49a7189c04b35",
  }
  known_tarballs.each do |vsn, md5|
    version vsn do
      source md5: md5, url: "http://production.cf.rubygems.org/rubygems/rubygems-#{vsn}.tgz"
      relative_path "rubygems-#{vsn}"
    end
  end
end

# If we still don't have a source (if it's a tarball) grab from ruby ...
if version && !source
  # If the version is a gem version, we"ll just be using rubygems.
  # If it's a branch or SHA (i.e. v1.2.3) we use github.
  begin
    Gem::Version.new(version)
  rescue ArgumentError
    source git: "https://github.com/rubygems/rubygems.git"
  end
end

# git repo is always expanded to "rubygems"
if source && source.include?(:git)
  relative_path "rubygems"
end

build do
  env = with_standard_compiler_flags(with_embedded_path)

  if source
    # Building from source:
    ruby "setup.rb --no-document", env: env
  else
    # Installing direct from rubygems:
    # If there is no version, this will get latest.
    gem "update --no-document --system #{version}", env: env
  end
end
