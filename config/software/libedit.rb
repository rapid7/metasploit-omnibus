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

name "libedit"
default_version "20120601-3.0"

dependency "ncurses"

version "20120601-3.0" do
  source md5: "e50f6a7afb4de00c81650f7b1a0f5aea"
end

version "20130712-3.1" do
  source md5: "0891336c697362727a1fa7e60c5cb96c"
end

source url: "http://www.thrysoee.dk/editline/libedit-#{version}.tar.gz"

relative_path "libedit-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # The patch is from the FreeBSD ports tree and is for GCC compatibility.
  # http://svnweb.freebsd.org/ports/head/devel/libedit/files/patch-vi.c?annotate=300896
  if freebsd?
    patch source: "freebsd-vi-fix.patch"
  end

  command "./configure" \
          " --prefix=#{install_dir}/embedded", env: env

  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env
end
