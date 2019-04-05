#
# Copyright 2012-2019, Chef Software Inc.
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

license "BSD-2-Clause"
license_file "BSDL"
license_file "COPYING"
license_file "LEGAL"
skip_transitive_dependency_licensing true

# the default versions should always be the latest release of ruby
# if you consume this definition it is your responsibility to pin
# to the desired version of ruby. don't count on this not changing.
default_version "2.6.1"

dependency "zlib"
dependency "openssl"
dependency "libffi"
dependency "libyaml"

version("2.6.2")      { source sha256: "a0405d2bf2c2d2f332033b70dff354d224a864ab0edd462b7a413420453b49ab" }
version("2.6.1")      { source sha256: "17024fb7bb203d9cf7a5a42c78ff6ce77140f9d083676044a7db67f1e5191cb8" }
version("2.5.5")      { source sha256: "28a945fdf340e6ba04fc890b98648342e3cccfd6d223a48f3810572f11b2514c" }
version("2.5.4")      { source sha256: "0e4042bce749352dfcf1b9e3013ba7c078b728f51f8adaf6470ce37675e3cb1f" }
version("2.5.3")      { source sha256: "9828d03852c37c20fa333a0264f2490f07338576734d910ee3fd538c9520846c" }
version("2.5.1")      { source sha256: "dac81822325b79c3ba9532b048c2123357d3310b2b40024202f360251d9829b1" }
version("2.5.0")      { source sha256: "46e6f3630f1888eb653b15fa811d77b5b1df6fd7a3af436b343cfe4f4503f2ab" }

version("2.4.5")      { source sha256: "6737741ae6ffa61174c8a3dcdd8ba92bc38827827ab1d7ea1ec78bc3cefc5198" }
version("2.4.4")      { source sha256: "254f1c1a79e4cc814d1e7320bc5bdd995dc57e08727d30a767664619a9c8ae5a" }
version("2.4.3")      { source sha256: "fd0375582c92045aa7d31854e724471fb469e11a4b08ff334d39052ccaaa3a98" }
version("2.4.2")      { source sha256: "93b9e75e00b262bc4def6b26b7ae8717efc252c47154abb7392e54357e6c8c9c" }
version("2.4.1")      { source sha256: "a330e10d5cb5e53b3a0078326c5731888bb55e32c4abfeb27d9e7f8e5d000250" }
version("2.4.0")      { source sha256: "152fd0bd15a90b4a18213448f485d4b53e9f7662e1508190aa5b702446b29e3d" }

version("2.3.8")      { source sha256: "b5016d61440e939045d4e22979e04708ed6c8e1c52e7edb2553cf40b73c59abf" }
version("2.3.7")      { source sha256: "35cd349cddf78e4a0640d28ec8c7e88a2ae0db51ebd8926cd232bb70db2c7d7f" }
version("2.3.6")      { source sha256: "8322513279f9edfa612d445bc111a87894fac1128eaa539301cebfc0dd51571e" }
version("2.3.5")      { source sha256: "5462f7bbb28beff5da7441968471ed922f964db1abdce82b8860608acc23ddcc" }
version("2.3.4")      { source sha256: "98e18f17c933318d0e32fed3aea67e304f174d03170a38fd920c4fbe49fec0c3" }
version("2.3.3")      { source sha256: "241408c8c555b258846368830a06146e4849a1d58dcaf6b14a3b6a73058115b7" }
version("2.3.1")      { source sha256: "b87c738cb2032bf4920fef8e3864dc5cf8eae9d89d8d523ce0236945c5797dcd" }
version("2.3.0")      { source md5: "e81740ac7b14a9f837e9573601db3162" }

version("2.2.10")     { source sha256: "cd51019eb9d9c786d6cb178c37f6812d8a41d6914a1edaf0050c051c75d7c358" }
version("2.2.9")      { source sha256: "2f47c77054fc40ccfde22501425256d32c4fa0ccaf9554f0d699ed436beca1a6" }
version("2.2.8")      { source sha256: "8f37b9d8538bf8e50ad098db2a716ea49585ad1601bbd347ef84ca0662d9268a" }

source url: "https://cache.ruby-lang.org/pub/ruby/#{version.match(/^(\d+\.\d+)/)[0]}/ruby-#{version}.tar.gz"

relative_path "ruby-#{version}"

env = with_standard_compiler_flags(with_embedded_path)

if mac_os_x?
  # -Qunused-arguments suppresses "argument unused during compilation"
  # warnings. These can be produced if you compile a program that doesn't
  # link to anything in a path given with -Lextra-libs. Normally these
  # would be harmless, except that autoconf treats any output to stderr as
  # a failure when it makes a test program to check your CFLAGS (regardless
  # of the actual exit code from the compiler).
  env["CFLAGS"] << " -I#{install_dir}/embedded/include/ncurses -arch x86_64 -m64 -O3 -g -pipe -Qunused-arguments"
  env["LDFLAGS"] << " -arch x86_64"
elsif freebsd?
  # Stops "libtinfo.so.5.9: could not read symbols: Bad value" error when
  # compiling ext/readline. See the following for more info:
  #
  #   https://lists.freebsd.org/pipermail/freebsd-current/2013-October/045425.html
  #   http://mailing.freebsd.ports-bugs.narkive.com/kCgK8sNQ/ports-183106-patch-sysutils-libcdio-does-not-build-on-10-0-and-head
  #
  env["LDFLAGS"] << " -ltinfow"
elsif aix?
  # this magic per IBM
  env["LDSHARED"] = "xlc -G"
  env["CFLAGS"] = "-I#{install_dir}/embedded/include/ncurses -I#{install_dir}/embedded/include"
  # this magic per IBM
  env["XCFLAGS"] = "-DRUBY_EXPORT"
  # need CPPFLAGS set so ruby doesn't try to be too clever
  env["CPPFLAGS"] = "-I#{install_dir}/embedded/include/ncurses -I#{install_dir}/embedded/include"
  env["SOLIBS"] = "-lm -lc"
  # need to use GNU m4, default m4 doesn't work
  env["M4"] = "/opt/freeware/bin/m4"
elsif solaris_11?
  env["CFLAGS"] << " -std=c99"
  env["CPPFLAGS"] << " -D_XOPEN_SOURCE=600 -D_XPG6"
elsif windows?
  env["CFLAGS"] = "-I#{install_dir}/embedded/include -DFD_SETSIZE=2048"
  if windows_arch_i386?
    # 32-bit windows can't compile ruby with -O2 due to compiler bugs.
    env["CFLAGS"] << " -m32 -march=i686 -O"
  else
    env["CFLAGS"] << " -m64 -march=x86-64 -O2"
  end
  env["CPPFLAGS"] = env["CFLAGS"]
  env["CXXFLAGS"] = env["CFLAGS"]
else # including linux
  if version.satisfies?(">= 2.3.0") &&
      rhel? && platform_version.satisfies?("< 6.0")
    env["CFLAGS"] << " -O2 -g -pipe"
  else
    env["CFLAGS"] << " -O3 -g -pipe"
  end
end

build do
  # AIX needs /opt/freeware/bin only for patch
  patch_env = env.dup
  patch_env["PATH"] = "/opt/freeware/bin:#{env['PATH']}" if aix?

  # wrlinux7/ios_xr build boxes from Cisco include libssp and there is no way to
  # disable ruby from linking against it, but Cisco switches will not have the
  # library.  Disabling it as we do for Solaris.
  if ios_xr?
    patch source: "ruby-no-stack-protector.patch", plevel: 1, env: patch_env
  end

  # disable libpath in mkmf across all platforms, it trolls omnibus and
  # breaks the postgresql cookbook.  i'm not sure why ruby authors decided
  # this was a good idea, but it breaks our use case hard.  AIX cannot even
  # compile without removing it, and it breaks some native gem installs on
  # other platforms.  generally you need to have a condition where the
  # embedded and non-embedded libs get into a fight (libiconv, openssl, etc)
  # and ruby trying to set LD_LIBRARY_PATH itself gets it wrong.
  #
  # Also, fix paths emitted in the makefile on windows on both msys and msys2.
  # should intentionally break and fail to apply on 2.2, patch will need to
  # be fixed.
  patch source: "ruby-mkmf.patch", plevel: 1, env: patch_env

  # Fix find_proxy with IP format proxy and domain format uri raises an exception.
  # This only affects 2.4 and the fix is expected to be included in 2.4.2
  # https://github.com/ruby/ruby/pull/1513
  if version == "2.4.0" || version == "2.4.1"
    patch source: "2.4_no_proxy_exception.patch", plevel: 1, env: patch_env
  end

  # RHEL 6's gcc doesn't support `#pragma GCC diagnostic` inside functions, so
  # we'll guard their inclusion more specifically. As of 2018-01-25 this is fixed
  # upstream and ought to be in 2.5.1
  if rhel? &&
      platform_version.satisfies?("< 7") &&
      (version == "2.5.0")
    patch source: "prelude_25_el6_no_pragma.patch", plevel: 0, env: patch_env
  end

  # Backporting a 2.6.0 fix to 2.5.1 (and 2.4.4 for ChefDK 2). This allows us to build Nokogiri 1.8.3.
  # Basically we only include `-Werror` linker warnings when building native gems if we are on Windows.
  # This prevents some "expected" warnings from failing the build.
  if version == "2.5.1" || version == "2.4.4"
    patch source: "ruby-only-compiler-warnings-on-windows.patch", plevel: 1, env: patch_env
  end

  configure_command = ["--with-out-ext=dbm,readline",
                       "--enable-shared",
                       "--disable-install-doc",
                       "--without-gmp",
                       "--without-gdbm",
                       "--without-tk",
                       "--disable-dtrace"]
  configure_command << "--with-ext=psych" if version.satisfies?("< 2.3")
  configure_command << "--with-bundled-md5" if fips_mode?

  # jit doesn't compile on all platforms in 2.6.0
  # we should evaluate this when new releases come out to see if we can turn it back on
  configure_command << "--disable-jit-support" if version.satisfies?(">= 2.6")

  if aix?
    # need to patch ruby's configure file so it knows how to find shared libraries
    if version.satisfies?(">= 2.6")
      patch source: "ruby-aix-configure_26_and_later.patch", plevel: 1, env: patch_env
    else
      patch source: "ruby-aix-configure_pre26.patch", plevel: 1, env: patch_env
    end
    # have ruby use zlib on AIX correctly
    patch source: "ruby_aix_openssl.patch", plevel: 1, env: patch_env
    # AIX has issues with ssl retries, need to patch to have it retry
    patch source: "ruby_aix_2_1_3_ssl_EAGAIN.patch", plevel: 1, env: patch_env
    # the next two patches are because xlc doesn't deal with long vs int types well
    patch source: "ruby-aix-atomic.patch", plevel: 1, env: patch_env
    patch source: "ruby-aix-vm-core.patch", plevel: 1, env: patch_env

    # per IBM, just help ruby along on what it's running on
    configure_command << "--host=powerpc-ibm-aix6.1.0.0 --target=powerpc-ibm-aix6.1.0.0 --build=powerpc-ibm-aix6.1.0.0 --enable-pthread"

  elsif freebsd?
    # Disable optional support C level backtrace support. This requires the
    # optional devel/libexecinfo port to be installed.
    configure_command << "ac_cv_header_execinfo_h=no"
    configure_command << "--with-opt-dir=#{install_dir}/embedded"
  elsif smartos?
    # Chef patch - sean@sean.io
    # GCC 4.7.0 chokes on mismatched function types between OpenSSL 1.0.1c and Ruby 1.9.3-p286
    # patch included upstream in Ruby 2.4.1
    patch source: "ruby-openssl-1.0.1c.patch", plevel: 1, env: patch_env unless version.satisfies?(">= 2.4.1")

    # Patches taken from RVM.
    # http://bugs.ruby-lang.org/issues/5384
    # https://www.illumos.org/issues/1587
    # https://github.com/wayneeseguin/rvm/issues/719
    patch source: "rvm-cflags.patch", plevel: 1, env: patch_env

    # From RVM forum
    # https://github.com/wayneeseguin/rvm/commit/86766534fcc26f4582f23842a4d3789707ce6b96
    configure_command << "ac_cv_func_dl_iterate_phdr=no"
    configure_command << "--with-opt-dir=#{install_dir}/embedded"
  elsif solaris2?
    # In ruby-2.5.0 on Solaris 11 Random.urandom defaults to arc4random_buf() as
    # its implementation which is buggy and returns nothing but zeros.  We therefore
    # force that API off.
    configure_command << "ac_cv_func_arc4random_buf=no"
  elsif windows?
    if version.satisfies?(">= 2.3") &&
        version.satisfies?("< 2.5")
      # Windows Nano Server COM libraries do not support Apartment threading
      # instead COINIT_MULTITHREADED must be used
      patch source: "ruby_nano.patch", plevel: 1, env: patch_env
    end

    configure_command << " debugflags=-g"
  else
    configure_command << "--with-opt-dir=#{install_dir}/embedded"
  end

  # This patch is expected to be included in 2.3.5 and is already in 2.4.1.
  if version == "2.3.4"
    patch source: "ruby_2_3_gcc7.patch", plevel: 0, env: patch_env
  end

  # FFS: works around a bug that infects AIX when it picks up our pkg-config
  # AFAIK, ruby does not need or use this pkg-config it just causes the build to fail.
  # The alternative would be to patch configure to remove all the pkg-config garbage entirely
  env["PKG_CONFIG"] = "/bin/true" if aix?

  configure(*configure_command, env: env)
  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env

  if windows?
    # Needed now that we switched to msys2 and have not figured out how to tell
    # it how to statically link yet
    dlls = [
      "libwinpthread-1",
      "libstdc++-6",
    ]
    if windows_arch_i386?
      dlls << "libgcc_s_dw2-1"
    else
      dlls << "libgcc_s_seh-1"
    end

    dlls.each do |dll|
      mingw = ENV["MSYSTEM"].downcase
      msys_path = ENV["OMNIBUS_TOOLCHAIN_INSTALL_DIR"] ? "#{ENV["OMNIBUS_TOOLCHAIN_INSTALL_DIR"]}/embedded/bin" : "C:/msys2"
      windows_path = "#{msys_path}/#{mingw}/bin/#{dll}.dll"
      if File.exist?(windows_path)
        copy windows_path, "#{install_dir}/embedded/bin/#{dll}.dll"
      else
        raise "Cannot find required DLL needed for dynamic linking: #{windows_path}"
      end
    end

    if version.satisfies?(">= 2.4")
      %w{ erb gem irb rdoc ri }.each do |cmd|
        copy "#{project_dir}/bin/#{cmd}", "#{install_dir}/embedded/bin/#{cmd}"
      end
    end

    # Ruby 2.4 seems to mark rake.bat as read-only.
    # Mark it as writable so that we can install other version of rake without
    # running into permission errors.
    command "attrib -r #{install_dir}/embedded/bin/rake.bat"

  end

end
