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

name "ruby"
default_version "2.1.5"

dependency "zlib"
dependency "ncurses"
dependency "libedit"
dependency "openssl"
dependency "libyaml"
dependency "libiconv"
dependency "libffi"
dependency "gdbm"

version("1.9.3-p484") { source md5: "8ac0dee72fe12d75c8b2d0ef5d0c2968" }
version("1.9.3-p547") { source md5: "7531f9b1b35b16f3eb3d7bea786babfd" }
version("1.9.3-p550") { source md5: "e05135be8f109b2845229c4f47f980fd" }
version("2.0.0-p576") { source md5: "2e1f4355981b754d92f7e2cc456f843d" }
version("2.0.0-p594") { source md5: "a9caa406da5d72f190e28344e747ee74" }
version("2.1.1")      { source md5: "e57fdbb8ed56e70c43f39c79da1654b2" }
version("2.1.2")      { source md5: "a5b5c83565f8bd954ee522bd287d2ca1" }
version("2.1.3")      { source md5: "74a37b9ad90e4ea63c0eed32b9d5b18f" }
version("2.1.4")      { source md5: "89b2f4a197621346f6724a3c35535b19" }
version("2.1.5")      { source md5: "df4c1b23f624a50513c7a78cb51a13dc" }

source url: "http://cache.ruby-lang.org/pub/ruby/#{version.match(/^(\d+\.\d+)/)[0]}/ruby-#{version}.tar.gz"

relative_path "ruby-#{version}"

env = with_standard_compiler_flags(with_embedded_path)

case ohai['platform']
when "mac_os_x"
  # -Qunused-arguments suppresses "argument unused during compilation"
  # warnings. These can be produced if you compile a program that doesn't
  # link to anything in a path given with -Lextra-libs. Normally these
  # would be harmless, except that autoconf treats any output to stderr as
  # a failure when it makes a test program to check your CFLAGS (regardless
  # of the actual exit code from the compiler).
  env['CFLAGS'] << " -I#{install_dir}/embedded/include/ncurses -arch x86_64 -m64 -O3 -g -pipe -Qunused-arguments"
  env['LDFLAGS'] << " -arch x86_64"
when "freebsd"
  # Stops "libtinfo.so.5.9: could not read symbols: Bad value" error when
  # compiling ext/readline. See the following for more info:
  #
  #   https://lists.freebsd.org/pipermail/freebsd-current/2013-October/045425.html
  #   http://mailing.freebsd.ports-bugs.narkive.com/kCgK8sNQ/ports-183106-patch-sysutils-libcdio-does-not-build-on-10-0-and-head
  #
  env['LDFLAGS'] << " -ltinfow"
when "aix"
  # this magic per IBM
  env['LDSHARED'] = "xlc -G"
  env['CFLAGS'] = "-I#{install_dir}/embedded/include/ncurses -I#{install_dir}/embedded/include"
  # this magic per IBM
  env['XCFLAGS'] = "-DRUBY_EXPORT"
  # need CPPFLAGS set so ruby doesn't try to be too clever
  env['CPPFLAGS'] = "-I#{install_dir}/embedded/include/ncurses -I#{install_dir}/embedded/include"
  env['SOLIBS'] = "-lm -lc"
  # need to use GNU m4, default m4 doesn't work
  env['M4'] = "/opt/freeware/bin/m4"
else  # including solaris, linux
  env['CFLAGS'] << " -O3 -g -pipe"
end

build do
  if solaris2? && version.to_f >= 2.1
    patch source: "ruby-solaris-no-stack-protector.patch", plevel: 1
  end

  # AIX needs /opt/freeware/bin only for patch
  patch_env = env.dup
  patch_env['PATH'] = "/opt/freeware/bin:#{env['PATH']}" if aix?

  # disable libpath in mkmf across all platforms, it trolls omnibus and
  # breaks the postgresql cookbook.  i'm not sure why ruby authors decided
  # this was a good idea, but it breaks our use case hard.  AIX cannot even
  # compile without removing it, and it breaks some native gem installs on
  # other platforms.  generally you need to have a condition where the
  # embedded and non-embedded libs get into a fight (libiconv, openssl, etc)
  # and ruby trying to set LD_LIBRARY_PATH itself gets it wrong.
  if version.to_f >= 2.1
    patch source: "ruby_aix_2_1_3_mkmf.patch", plevel: 1, env: patch_env
    # should intentionally break and fail to apply on 2.2, patch will need to
    # be fixed.
  end

  configure_command = ["./configure",
                       "--prefix=#{install_dir}/embedded",
                       "--with-out-ext=dbm",
                       "--enable-shared",
                       "--enable-libedit",
                       "--with-ext=psych",
                       "--disable-install-doc",
                       "--without-gmp",
                       "--disable-dtrace"]

  case ohai['platform']
  when "aix"
    # need to patch ruby's configure file so it knows how to find shared libraries
    patch source: "ruby-aix-configure.patch", plevel: 1, env: patch_env
    # have ruby use zlib on AIX correctly
    patch source: "ruby_aix_openssl.patch", plevel: 1, env: patch_env
    # AIX has issues with ssl retries, need to patch to have it retry
    patch source: "ruby_aix_2_1_3_ssl_EAGAIN.patch", plevel: 1, env: patch_env
    # the next two patches are because xlc doesn't deal with long vs int types well
    patch source: "ruby-aix-atomic.patch", plevel: 1, env: patch_env
    patch source: "ruby-aix-vm-core.patch", plevel: 1, env: patch_env

    # per IBM, just help ruby along on what it's running on
    configure_command << "--host=powerpc-ibm-aix6.1.0.0 --target=powerpc-ibm-aix6.1.0.0 --build=powerpc-ibm-aix6.1.0.0 --enable-pthread"

  when "freebsd"
    # Disable optional support C level backtrace support. This requires the
    # optional devel/libexecinfo port to be installed.
    configure_command << "ac_cv_header_execinfo_h=no"
    configure_command << "--with-opt-dir=#{install_dir}/embedded"
  when "smartos"
    # Opscode patch - someara@opscode.com
    # GCC 4.7.0 chokes on mismatched function types between OpenSSL 1.0.1c and Ruby 1.9.3-p286
    patch source: "ruby-openssl-1.0.1c.patch", plevel: 1

    # Patches taken from RVM.
    # http://bugs.ruby-lang.org/issues/5384
    # https://www.illumos.org/issues/1587
    # https://github.com/wayneeseguin/rvm/issues/719
    patch source: "rvm-cflags.patch", plevel: 1

    # From RVM forum
    # https://github.com/wayneeseguin/rvm/commit/86766534fcc26f4582f23842a4d3789707ce6b96
    configure_command << "ac_cv_func_dl_iterate_phdr=no"
    configure_command << "--with-opt-dir=#{install_dir}/embedded"
  else
    configure_command << "--with-opt-dir=#{install_dir}/embedded"
  end

  # FFS: works around a bug that infects AIX when it picks up our pkg-config
  # AFAIK, ruby does not need or use this pkg-config it just causes the build to fail.
  # The alternative would be to patch configure to remove all the pkg-config garbage entirely
  env.merge!("PKG_CONFIG" => "/bin/true") if aix?

  command configure_command.join(" "), env: env
  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env

end
