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

name "openssl"

license "OpenSSL"
license_file "LICENSE"

fips_enabled = (project.overrides[:fips] && project.overrides[:fips][:enabled]) || false

dependency "zlib"
dependency "cacerts"
dependency "makedepend" unless aix? || windows?
dependency "patch" if solaris_10?
dependency "openssl-fips" if fips_enabled

default_version "1.0.1t"

# OpenSSL source ships with broken symlinks which windows doesn't allow.
# Skip error checking.
source url: "https://www.openssl.org/source/openssl-#{version}.tar.gz", extract: :lax_tar

# We have not tested version 1.0.2. It's here so we can run experimental builds
# to verify that it still compiles on all our platforms.
version("1.0.2g") { source md5: "f3c710c045cdee5fd114feb69feba7aa" }
version("1.0.1t") { source md5: "9837746fcf8a6727d46d22ca35953da1" }
version("1.0.1s") { source md5: "562986f6937aabc7c11a6d376d8a0d26" }
version("1.0.1r") { source md5: "1abd905e079542ccae948af37e393d28" }

relative_path "openssl-#{version}"

build do

  env = with_standard_compiler_flags(with_embedded_path({}, msys: true), bfd_flags: true)
  if aix?
    env["M4"] = "/opt/freeware/bin/m4"
  elsif freebsd?
    # Should this just be in standard_compiler_flags?
    env['LDFLAGS'] += " -Wl,-rpath,#{install_dir}/embedded/lib"
  elsif windows?
    # XXX: OpenSSL explicitly sets -march=i486 and expects that to be honored.
    # It has OPENSSL_IA32_SSE2 controlling whether it emits optimized SSE2 code
    # and the 32-bit calling convention involving XMM registers is...  vague.
    # Do not enable SSE2 generally because the hand optimized assembly will
    # overwrite registers that mingw expects to get preserved.
    arch_flag = windows_arch_i386? ? "-m32" : "-m64"
    env['CFLAGS'] = "-I#{install_dir}/embedded/include #{arch_flag}"
    env['CPPFLAGS'] = env['CFLAGS']
    env['CXXFLAGS'] = env['CFLAGS']
  end

  configure_args = [
    "--prefix=#{install_dir}/embedded",
    "--with-zlib-lib=#{install_dir}/embedded/lib",
    "--with-zlib-include=#{install_dir}/embedded/include",
    "no-idea",
    "no-mdc2",
    "no-rc5",
    "shared",
  ]

  if fips_enabled
    configure_args << "--with-fipsdir=#{install_dir}/embedded" << "fips"
  end

  if windows?
    configure_args << "zlib-dynamic"
  else
    configure_args << "zlib"
  end

  configure_cmd =
    if aix?
      "perl ./Configure aix64-cc"
    elsif mac_os_x?
      "./Configure darwin64-x86_64-cc"
    elsif smartos?
      "/bin/bash ./Configure solaris64-x86_64-gcc -static-libgcc"
    elsif solaris_10?
      # This should not require a /bin/sh, but without it we get
      # Errno::ENOEXEC: Exec format error
      platform = sparc? ? "solaris-sparcv9-gcc" : "solaris-x86-gcc"
      "/bin/sh ./Configure #{platform}"
    elsif solaris_11?
      "/bin/bash ./Configure solaris64-x86_64-gcc -static-libgcc"
    elsif windows?
      platform = windows_arch_i386? ? "mingw" : "mingw64"
      "perl.exe ./Configure #{platform}"
    else
      prefix =
        if linux? && ppc64?
          "./Configure linux-ppc64"
        elsif linux? && ohai["kernel"]["machine"] == "s390x"
          "./Configure linux64-s390x"
        else
          "./config"
        end
      "#{prefix} disable-gost"
    end

  if aix?

    # This enables omnibus to use 'makedepend'
    # from fileset 'X11.adt.imake' (AIX install media)
    env['PATH'] = "/usr/lpp/X11/bin:#{ENV["PATH"]}"

    patch_env = env.dup
    patch_env['PATH'] = "/opt/freeware/bin:#{env['PATH']}"
    patch source: "openssl-1.0.1f-do-not-build-docs.patch", env: patch_env
  else
    patch source: "openssl-1.0.1f-do-not-build-docs.patch", env: env
  end

  if windows?
    # Patch Makefile.shared to let us set the bit-ness of the resource compiler.
    patch source: "openssl-1.0.1q-take-windres-rcflags.patch", env: env
    # Patch Makefile.org to update the compiler flags/options table for mingw.
    patch source: "openssl-1.0.1q-fix-compiler-flags-table-for-msys.patch", env: env
    # Patch Configure to call ar.exe without anooying it.
    patch source: "openssl-1.0.1q-ar-needs-operation-before-target.patch", env: env
  end

  # Out of abundance of caution, we put the feature flags first and then
  # the crazy platform specific compiler flags at the end.
  configure_args << env['CFLAGS'] << env['LDFLAGS']

  configure_command = configure_args.unshift(configure_cmd).join(" ")

  command configure_command, env: env, in_msys_bash: true
  make "depend", env: env
  # make -j N on openssl is not reliable
  make env: env
  if aix?
    # We have to sudo this because you can't actually run slibclean without being root.
    # Something in openssl changed in the build process so now it loads the libcrypto
    # and libssl libraries into AIX's shared library space during the first part of the
    # compile. This means we need to clear the space since it's not being used and we
    # can't install the library that is already in use. Ideally we would patch openssl
    # to make this not be an issue.
    # Bug Ref: http://rt.openssl.org/Ticket/Display.html?id=2986&user=guest&pass=guest
    command "sudo /usr/sbin/slibclean", env: env
  end
  make "install", env: env
end
