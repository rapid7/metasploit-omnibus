#
# Copyright:: Copyright (c) Chef Software Inc.
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
# do_not_auto_update

name "ruby"

license "BSD-2-Clause"
license_file "BSDL"
license_file "COPYING"
license_file "LEGAL"
skip_transitive_dependency_licensing true

# the default versions should always be the latest release of ruby
# if you consume this definition it is your responsibility to pin
# to the desired version of ruby. don't count on this not changing.
default_version "3.1.5"

dependency "zlib"
dependency "openssl"
dependency "libffi"
dependency "libyaml"

# we build omnibus packages on freebsd 11 and use the packages on freebsd 11, 12 and 13.
# the ruby executable has been linking to freebsds system's ncurses library files.
# freebsd 13 system's ncurses library files have a different name than freebsd 11 and 12
# which causes the ruby executable to fail.
# adding ncurses as a dependency for freebsd prevents the ruby executable from linking to the
# system's ncurses library files thereby allowing the package built on freebsd 11 to work on freebsd 13.
dependency "ncurses" if freebsd?

# version_list: url=https://cache.ruby-lang.org/pub/ruby/ filter=*.tar.gz
version("3.2.2")      { source sha256: "96c57558871a6748de5bc9f274e93f4b5aad06cd8f37befa0e8d94e7b8a423bc" }
version("3.2.0")      { source sha256: "daaa78e1360b2783f98deeceb677ad900f3a36c0ffa6e2b6b19090be77abc272" }
version("3.1.4")      { source sha256: "a3d55879a0dfab1d7141fdf10d22a07dbf8e5cdc4415da1bde06127d5cc3c7b6" }
version("3.1.5")      { source sha256: "3685c51eeee1352c31ea039706d71976f53d00ab6d77312de6aa1abaf5cda2c5" }
version("3.1.3")      { source sha256: "5ea498a35f4cd15875200a52dde42b6eb179e1264e17d78732c3a57cd1c6ab9e" }
version("3.1.2")      { source sha256: "61843112389f02b735428b53bb64cf988ad9fb81858b8248e22e57336f24a83e" }
version("3.1.1")      { source sha256: "fe6e4782de97443978ddba8ba4be38d222aa24dc3e3f02a6a8e7701c0eeb619d" }

version("3.0.6")      { source sha256: "6e6cbd490030d7910c0ff20edefab4294dfcd1046f0f8f47f78b597987ac683e" }
version("3.0.5")      { source sha256: "9afc6380a027a4fe1ae1a3e2eccb6b497b9c5ac0631c12ca56f9b7beb4848776" }
version("3.0.4")      { source sha256: "70b47c207af04bce9acea262308fb42893d3e244f39a4abc586920a1c723722b" }
version("3.0.3")      { source sha256: "3586861cb2df56970287f0fd83f274bd92058872d830d15570b36def7f1a92ac" }
version("3.0.2")      { source sha256: "5085dee0ad9f06996a8acec7ebea4a8735e6fac22f22e2d98c3f2bc3bef7e6f1" }
version("3.0.1")      { source sha256: "369825db2199f6aeef16b408df6a04ebaddb664fb9af0ec8c686b0ce7ab77727" }

version("2.7.7")      { source sha256: "e10127db691d7ff36402cfe88f418c8d025a3f1eea92044b162dd72f0b8c7b90" }
version("2.7.6")      { source sha256: "e7203b0cc09442ed2c08936d483f8ac140ec1c72e37bb5c401646b7866cb5d10" }
version("2.7.5")      { source sha256: "2755b900a21235b443bb16dadd9032f784d4a88f143d852bc5d154f22b8781f1" }
version("2.7.4")      { source sha256: "3043099089608859fc8cce7f9fdccaa1f53a462457e3838ec3b25a7d609fbc5b" }
version("2.7.3")      { source sha256: "8925a95e31d8f2c81749025a52a544ea1d05dad18794e6828709268b92e55338" }

version("2.6.10")     { source sha256: "0dc609f263d49c4176d5725deefc337273676395985b5e017789373e8cadf16e" }
version("2.6.9")      { source sha256: "eb7bae7aac64bf9eb2153710a4cafae450ccbb62ae6f63d573e1786178b0efbb" }
version("2.6.8")      { source sha256: "1807b78577bc08596a390e8a41aede37b8512190e05c133b17d0501791a8ca6d" }
version("2.6.7")      { source sha256: "e4227e8b7f65485ecb73397a83e0d09dcd39f25efd411c782b69424e55c7a99e" }

source url: "https://cache.ruby-lang.org/pub/ruby/#{version.match(/^(\d+\.\d+)/)[0]}/ruby-#{version}.tar.gz"
internal_source url: "#{ENV["ARTIFACTORY_REPO_URL"]}/#{name}/#{name}-#{version}.tar.gz",
                authorization: "X-JFrog-Art-Api:#{ENV["ARTIFACTORY_TOKEN"]}"

# In order to pass notarization we need to sign any binaries and libraries included in the package.
# This makes sure we include and bins and libs that are brought in by gems.
semver = Gem::Version.create(version).segments
ruby_mmv = "#{semver[0..1].join(".")}.0"
ruby_dir = "#{install_dir}/embedded/lib/ruby/#{ruby_mmv}"
gem_dir = "#{install_dir}/embedded/lib/ruby/gems/#{ruby_mmv}"
bin_dirs bin_dirs.concat ["#{gem_dir}/gems/*/bin/**"]
lib_dirs ["#{ruby_dir}/**", "#{gem_dir}/extensions/**", "#{gem_dir}/gems/*", "#{gem_dir}/gems/*/lib/**", "#{gem_dir}/gems/*/ext/**"]

relative_path "ruby-#{version}"

env = with_standard_compiler_flags(with_embedded_path)

# do not remove - Rapid7 custom - do not remove:
jemalloc_required = (linux? && !arm?) || mac_os_x?
if jemalloc_required
  dependency "jemalloc"
end

if mac_os_x?
  # -Qunused-arguments suppresses "argument unused during compilation"
  # warnings. These can be produced if you compile a program that doesn't
  # link to anything in a path given with -Lextra-libs. Normally these
  # would be harmless, except that autoconf treats any output to stderr as
  # a failure when it makes a test program to check your CFLAGS (regardless
  # of the actual exit code from the compiler).
  arch = intel? ? "x86_64" : "arm64"
  env["CFLAGS"] << " -I#{install_dir}/embedded/include/ncurses -arch #{arch} -m64 -O3 -g -pipe -Qunused-arguments"
  env["LDFLAGS"] << " -arch #{arch}"
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
elsif solaris2?
  env["CXXFLAGS"] = "#{env["CXXFLAGS"]} -std=c++0x"
elsif windows?
  # this forces ruby >= 3.0 to pick up the gcc in the devkit rather than the cc in /opt/omnibus-toolchain
  # which is necessary for mkmf.rb to be able to correctly build native gems.  in an ideal world the compilation
  # environment in omnibus-toolchain would probably need to look a little more identical to the devkit.
  env["CC"] = "gcc"
  env["CFLAGS"] = "-I#{install_dir}/embedded/include -DFD_SETSIZE=2048"
  if windows_arch_i386?
    env["CFLAGS"] << " -m32 -march=i686 -O3"
  else
    env["CFLAGS"] << " -m64 -march=x86-64 -O3"
  end
  env["CPPFLAGS"] = env["CFLAGS"]
  env["CXXFLAGS"] = env["CFLAGS"]
else # including linux
  env["CFLAGS"] << " -O3 -g -pipe"
end

build do
  # AIX needs /opt/freeware/bin only for patch
  patch_env = env.dup
  patch_env["PATH"] = "/opt/freeware/bin:#{env["PATH"]}" if aix?

  if version.satisfies?("~> 3.0.0")
    case version
    when "3.0.1"
      patch source: "ruby-3.0.1-configure.patch", plevel: 1, env: patch_env
    when "3.0.5", "3.0.6"
      patch source: "ruby-3.0.5-configure.patch", plevel: 1, env: patch_env
    else
      patch source: "ruby-3.0.2-configure.patch", plevel: 1, env: patch_env
    end
  end

  # remove the warning that the win32 api is going away.
  if windows? && version.satisfies?("< 3.0")
    patch source: "ruby-win32_warning_removal.patch", plevel: 1, env: patch_env
  end

  # RHEL6 has a base compiler that does not support -fstack-protector-strong, but we
  # cannot build modern ruby on the RHEL6 base compiler, and the configure script
  # determines that it supports that flag and so includes it and then ultimately
  # pushes that into native gem compilations which then blows up for end users when
  # they try to install native gems.  So, we have to hack this up to avoid using
  # that flag on RHEL6.
  #
  if rhel? && platform_version.satisfies?("< 7")
    patch source: "ruby-no-stack-protector-strong.patch", plevel: 1, env: patch_env
  end

  # accelerate requires of c-extension.
  #
  # this would break code which did `require "thing"` and loaded thing.so and
  # then fiddled with the libpath and did `require "thing"` and loaded thing.rb
  # over the top of it.  AFAIK no sane ruby code should need to do that, and the
  # cost of this behavior in core ruby is enormous.
  #
  if version.satisfies?("< 3.1")
    patch source: "ruby-fast-load_26.patch", plevel: 1, env: patch_env
  else
    patch source: "ruby-fast-load_31.patch", plevel: 1, env: patch_env
  end

  # this removes a checks for windows nano in the win32-ole files.
  # windows nano is a dead platform and not supported by chef so we can avoid
  # registry lookups by patching away this code
  if windows?
    patch source: "remove_nano.patch", plevel: 1, env: patch_env
  end

  # accelerate requires by removing a File.expand_path
  #
  # the expand_path here seems to be largely useless and produces a large amount
  # of lstat(2) calls on unix, and increases the runtime of a chef-client --version
  # test by 33% on windows.  on modern linuxen that have openat(2) it is totally
  # useless.  this patch breaks no built-in tests on ruby on old platforms, and
  # it is unclear why or if it is necessary (hand crafted tests designed to try to
  # abuse it all succeeded after this test).
  #
  if version.satisfies?("~> 2.6.0")
    patch source: "ruby-faster-load_26.patch", plevel: 1, env: patch_env
  end
  if version.satisfies?(">= 2.7")
    patch source: "ruby-faster-load_27.patch", plevel: 1, env: patch_env
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
  patch source: "ruby-mkmf.patch", plevel: 1, env: patch_env

  configure_command = ["--with-out-ext=dbm,readline",
                       "--enable-shared",
                       # do not remove - Rapid7 custom - do not remove:
                       "--enable-load-relative",
                       "--disable-install-doc",
                       "--without-gmp",
                       "--without-gdbm",
                       "--without-tk",
                       "--disable-dtrace",
                       "--disable-jit-support"]
  configure_command << "--with-bundled-md5" if fips_mode?
  # do not remove - Rapid7 custom - do not remove:
  configure_command << "--with-jemalloc" if jemalloc_required

  # resolve C99 code accidentally introduced in Ruby 2.6.7 and it's still in 2.6.8 :(
  patch source: "ruby-2.6.7_c99.patch", plevel: 1, env: patch_env if version.satisfies?("~> 2.6.7", "< 2.6.10")

  if aix?
    # need to patch ruby's configure file so it knows how to find shared libraries
    patch source: "ruby-aix-configure_26_and_later.patch", plevel: 1, env: patch_env

    # have ruby use zlib on AIX correctly
    patch source: "ruby_aix_openssl.patch", plevel: 1, env: patch_env
    # AIX has issues with ssl retries, need to patch to have it retry
    patch source: "ruby_aix_ssl_EAGAIN.patch", plevel: 1, env: patch_env
    # the next two patches are because xlc doesn't deal with long vs int types well
    patch source: "ruby-aix-atomic.patch", plevel: 1, env: patch_env if version.satisfies?("< 3.0")
    patch source: "ruby-aix-vm-core.patch", plevel: 1, env: patch_env if version.satisfies?("< 3.0")

    # per IBM, just enable pthread
    configure_command << "--enable-pthread"

  elsif freebsd?
    # Disable optional support C level backtrace support. This requires the
    # optional devel/libexecinfo port to be installed.
    configure_command << "ac_cv_header_execinfo_h=no"
    configure_command << "--with-opt-dir=#{install_dir}/embedded"
  elsif smartos?
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
    configure_command << "debugflags=-g"
    configure_command << "--with-winnt-ver=0x0602" # the default is 0x0600 which is Vista. 602 is Windows 8 (2012)
  else
    configure_command << "--with-opt-dir=#{install_dir}/embedded"
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
      # Starting omnibus-toolchain version 1.1.115 we do not build msys2 as a part of omnibus-toolchain anymore, but pre install it in image
      # so here we set the path to default install of msys2 first and default to OMNIBUS_TOOLCHAIN_INSTALL_DIR for backward compatibility
      msys_path = ENV["MSYS2_INSTALL_DIR"] ? "#{ENV["MSYS2_INSTALL_DIR"]}" : "#{ENV["OMNIBUS_TOOLCHAIN_INSTALL_DIR"]}/embedded/bin"
      windows_path = "#{msys_path}/#{mingw}/bin/#{dll}.dll"
      if File.exist?(windows_path)
        copy windows_path, "#{install_dir}/embedded/bin/#{dll}.dll"
      else
        raise "Cannot find required DLL needed for dynamic linking: #{windows_path}"
      end
    end

    %w{ erb gem irb rdoc ri bundle }.each do |cmd|
      copy "#{project_dir}/bin/#{cmd}", "#{install_dir}/embedded/bin/#{cmd}"
    end

    # Ruby seems to mark rake.bat as read-only.
    # Mark it as writable so that we can install other version of rake without
    # running into permission errors.
    command "attrib -r #{install_dir}/embedded/bin/rake.bat"

  end

end
