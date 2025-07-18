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

default_version "3.6.7"

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
    "3.2.22" => "b128d5493da2ec7a1da49a7189c04b35",
    "3.3.26" => "ba171c52fd9beda6dac7194413601795",
    "3.5.10" => "70f46c096b4e11c42b0190cc3e3375e2",
    "3.6.7" => "4e8c5641f8dc7b6cac5a4bb8d423174f"
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

  # Fix warning on msfconsle bootup that will be fixed when framework's bundler version is updated
  #   NOTE: Gem::Platform.match is deprecated; use Gem::Platform.match_spec? or match_gem? instead. It will be removed in Rubygems 4
  #   Gem::Platform.match called from /Users/adfoster/.rvm/gems/ruby-3.3.0/gems/bundler-2.1.4/lib/bundler/index.rb:198.
  if version.satisfies?('>= 3.5.10')
    patch source: "rubygems-3.5.10.patch", plevel: 1, env: env
  end

  if source
    # Building from source:
    ruby "setup.rb --no-document", env: env
  else
    # Installing direct from rubygems:
    # If there is no version, this will get latest.
    gem "update --no-document --system #{version}", env: env
  end
end
