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

name "nokogiri"
default_version "1.6.7.2"

if windows?
  dependency "ruby-windows"
  dependency "ruby-windows-devkit"
else
  dependency "ruby"
  dependency "libxml2"
  dependency "libxslt"
  dependency "libiconv"
  dependency "liblzma"
  dependency "zlib"
end

dependency "rubygems"

#
# NOTE: As of nokogiri 1.6.4 it will superficially 'work' to remove most
# of the nonsense in this file and simply gem install nokogiri on most
# platforms.  This is because nokogiri has improved its packaging so that
# all of the dynamic libraries are 'statically' compiled into nokogiri.so
# with -lz -llzma -lxslt -lxml2, etc.  What will happen in that case is
# that the nokogiri build system will pull zlib, lzma, etc out of the
# system and link it inside of nokogiri.so and ship it as one big
# dynamic library.  This will essentially defeat one aspect of our
# health_check system so that we will be shipping an embedded zlib inside
# of nokogiri.so that we do not track and will have a high likelihood that
# if there are security errata that we ship exploitable code without
# knowing it.  For all other purposes, the built executable will work,
# however, so it is likely that someone will 'discover' that 'everything
# works' and remove all the junk in this file.  That will, however, have
# unintended side effects.  We do not have a mechanism to inspect the
# nokogiri.so and determine that it is shipping with an embedded zlib that
# does not match the one that we ship in /opt/chef/embedded/lib, so there
# will be nothing that alerts or fails on this.
#
# TL;DR: do not remove --use-system-libraries even if everything appears to
# be green after you do.
#
build do
  env = with_standard_compiler_flags(with_embedded_path)

  if windows?
    # use the 'fat' precompiled binary bundled with nokogiri
    gem "install nokogiri" \
      " --version '#{version}'", env: env
  else
    # Tell nokogiri to use the system libraries instead of compiling its own
    env["NOKOGIRI_USE_SYSTEM_LIBRARIES"] = "true"

    gem "install nokogiri" \
      " --version '#{version}'" \
      " --" \
      " --use-system-libraries" \
      " --with-xml2-lib=#{install_dir}/embedded/lib" \
      " --with-xml2-include=#{install_dir}/embedded/include/libxml2" \
      " --with-xslt-lib=#{install_dir}/embedded/lib" \
      " --with-xslt-include=#{install_dir}/embedded/include/libxslt" \
      " --with-iconv-dir=#{install_dir}/embedded" \
      " --with-zlib-dir=#{install_dir}/embedded", env: env
  end
end
