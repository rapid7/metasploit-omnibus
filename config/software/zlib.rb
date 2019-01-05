#
# Copyright 2012-2015 Chef Software, Inc.
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

name "zlib"
default_version "1.2.11"

version "1.2.11" do
  source md5: "1c9f62f0778697a09d36121ead88e08e"
end
version "1.2.8" do
  source md5: "44d667c142d7cda120332623eab69f40"
end
version "1.2.6" do
  source md5: "618e944d7c7cd6521551e30b32322f4a"
end

source url: "http://downloads.sourceforge.net/project/libpng/zlib/#{version}/zlib-#{version}.tar.gz"

license "Zlib"
license_file "README"
skip_transitive_dependency_licensing true

relative_path "zlib-#{version}"

build do
  if windows?
    env = with_standard_compiler_flags(with_embedded_path)

    patch source: "zlib-windows-relocate.patch", env: env

    # We can't use the top-level Makefile. Instead, the developers have made
    # an organic, artisanal, hand-crafted Makefile.gcc for us which takes a few
    # variables.
    env["BINARY_PATH"] = "/bin"
    env["LIBRARY_PATH"] = "/lib"
    env["INCLUDE_PATH"] = "/include"
    env["DESTDIR"] = "#{install_dir}/embedded"

    make_args = [
      "-fwin32/Makefile.gcc",
      "SHARED_MODE=1",
      "CFLAGS=\"#{env['CFLAGS']} -Wall\"",
      "ASFLAGS=\"#{env['CFLAGS']} -Wall\"",
      "LDFLAGS=\"#{env['LDFLAGS']}\"",
      # The win32 makefile for zlib does not handle parallel make correctly.
      # In particular, see its rule for IMPLIB and SHAREDLIB. The ld step in
      # SHAREDLIB will generate both the dll and the dll.a files. The step to
      # strip the dll occurs next but since the dll.a file is already present,
      # make will attempt to link example_d.exe and minigzip_d.exe in parallel
      # with the strip step - causing gcc to freak out when a source file is
      # rewritten part way through the linking stage.
      #"-j #{workers}",
    ]

    make(*make_args, env: env)
    make("install", *make_args, env: env)
  else
    # We omit the omnibus path here because it breaks mac_os_x builds by picking
    # up the embedded libtool instead of the system libtool which the zlib
    # configure script cannot handle.
    # TODO: Do other OSes need this?  Is this strictly a mac thing?
    env = with_standard_compiler_flags
    if freebsd?
      # FreeBSD 10+ gets cranky if zlib is not compiled in a
      # position-independent way.
      env["CFLAGS"] << " -fPIC"
    end

    configure env: env

    make "-j #{workers}", env: env
    make "-j #{workers} install", env: env
  end
end
