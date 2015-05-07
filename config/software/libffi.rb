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

name "libffi"

default_version "3.2.1"

dependency "libtool"

version("3.0.13") { source md5: "45f3b6dbc9ee7c7dfbbbc5feba571529" }
version("3.2.1")  { source md5: "83b89587607e3eb65c70d361f13bab43" }

source url: "ftp://sourceware.org/pub/libffi/libffi-#{version}.tar.gz"

relative_path "libffi-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  env['INSTALL'] = "/opt/freeware/bin/install" if ohai['platform'] == "aix"

  command "./configure" \
          " --prefix=#{install_dir}/embedded", env: env

  if solaris2?
    # run old make :(
    make env: env, bin: "/usr/ccs/bin/make"
    make "install", env: env, bin: "/usr/ccs/bin/make"
  else
    make "-j #{workers}", env: env
    make "-j #{workers} install", env: env
  end

  # libffi's default install location of header files is awful...
  copy "#{install_dir}/embedded/lib/libffi-#{version}/include/*", "#{install_dir}/embedded/include"

  # On 64-bit centos, libffi libraries are places under /embedded/lib64
  # move them over to lib
  if rhel? && _64_bit?
    # Can't use 'move' here since that uses FileUtils.mv, which on < Ruby 2.2.0-dev
    # returns ENOENT on moving symlinks with broken (in this case, already moved) targets.
    # http://comments.gmane.org/gmane.comp.lang.ruby.cvs/49907
    copy "#{install_dir}/embedded/lib64/*", "#{install_dir}/embedded/lib/"
    delete "#{install_dir}/embedded/lib64"
  end
end
