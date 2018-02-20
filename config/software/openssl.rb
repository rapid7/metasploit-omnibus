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
skip_transitive_dependency_licensing true

dependency "zlib"
dependency "cacerts"
dependency "makedepend" unless aix? || windows?
dependency "openssl-fips" if fips_mode?

default_version "1.0.2n"

# OpenSSL source ships with broken symlinks which windows doesn't allow.
# Skip error checking.
source url: "https://www.openssl.org/source/openssl-#{version}.tar.gz", extract: :lax_tar

version("1.1.0g") { source sha256: "de4d501267da39310905cb6dc8c6121f7a2cad45a7707f76df828fe1b85073af" }
version("1.1.0f") { source sha256: "12f746f3f2493b2f39da7ecf63d7ee19c6ac9ec6a4fcd8c229da8a522cb12765" }
version("1.0.2n") { source sha256: "370babb75f278c39e0c50e8c4e7493bc0f18db6867478341a832a982fd15a8fe" }
version("1.0.2m") { source sha256: "8c6ff15ec6b319b50788f42c7abc2890c08ba5a1cdcd3810eb9092deada37b0f" }
version("1.0.2l") { source sha256: "ce07195b659e75f4e1db43552860070061f156a98bb37b672b101ba6e3ddf30c" }
version("1.0.2k") { source sha256: "6b3977c61f2aedf0f96367dcfb5c6e578cf37e7b8d913b4ecb6643c3cb88d8c0" }
version("1.0.2j") { source sha256: "e7aff292be21c259c6af26469c7a9b3ba26e9abaaffd325e3dccc9785256c431" }
version("1.0.2i") { source sha256: "9287487d11c9545b6efb287cdb70535d4e9b284dd10d51441d9b9963d000de6f" }
version("1.0.2h") { source sha256: "1d4007e53aad94a5b2002fe045ee7bb0b3d98f1a47f8b2bc851dcd1c74332919" }
version("1.0.2g") { source sha256: "b784b1b3907ce39abf4098702dade6365522a253ad1552e267a9a0e89594aa33" }
version("1.0.1u") { source sha256: "4312b4ca1215b6f2c97007503d80db80d5157f76f8f7d3febbe6b4c56ff26739" }
version("1.0.1t") { source sha256: "4a6ee491a2fdb22e519c76fdc2a628bb3cec12762cd456861d207996c8a07088" }
version("1.0.1s") { source sha256: "e7e81d82f3cd538ab0cdba494006d44aab9dd96b7f6233ce9971fb7c7916d511" }
version("1.0.1r") { source sha256: "784bd8d355ed01ce98b812f873f8b2313da61df7c7b5677fcf2e57b0863a3346" }

relative_path "openssl-#{version}"

build do

  env = with_standard_compiler_flags(with_embedded_path)
  if aix?
    env["M4"] = "/opt/freeware/bin/m4"
  elsif freebsd?
    # Should this just be in standard_compiler_flags?
    env["LDFLAGS"] += " -Wl,-rpath,#{install_dir}/embedded/lib"
  elsif windows?
    # XXX: OpenSSL explicitly sets -march=i486 and expects that to be honored.
    # It has OPENSSL_IA32_SSE2 controlling whether it emits optimized SSE2 code
    # and the 32-bit calling convention involving XMM registers is...  vague.
    # Do not enable SSE2 generally because the hand optimized assembly will
    # overwrite registers that mingw expects to get preserved.
    env["CFLAGS"] = "-I#{install_dir}/embedded/include"
    env["CPPFLAGS"] = env["CFLAGS"]
    env["CXXFLAGS"] = env["CFLAGS"]
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

  configure_args += ["--with-fipsdir=#{install_dir}/embedded", "fips"] if fips_mode?

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
    elsif omnios?
      "/bin/bash ./Configure solaris-x86-gcc"
    elsif solaris_10?
      # This should not require a /bin/sh, but without it we get
      # Errno::ENOEXEC: Exec format error
      platform = sparc? ? "solaris-sparcv9-gcc" : "solaris-x86-gcc"
      "/bin/sh ./Configure #{platform} -static-libgcc"
    elsif solaris_11?
      platform = sparc? ? "solaris64-sparcv9-gcc" : "solaris64-x86_64-gcc"
      "/bin/bash ./Configure #{platform} -static-libgcc"
    elsif windows?
      platform = windows_arch_i386? ? "mingw" : "mingw64"
      "perl.exe ./Configure #{platform}"
    else
      prefix =
        if linux? && ppc64?
          "./Configure linux-ppc64"
        elsif linux? && s390x?
          # With gcc > 4.3 on s390x there is an error building
          # with inline asm enabled
          "./Configure linux64-s390x -DOPENSSL_NO_INLINE_ASM"
        else
          "./config"
        end
      "#{prefix} disable-gost"
    end

  patch_env = if aix?
                # This enables omnibus to use 'makedepend'
                # from fileset 'X11.adt.imake' (AIX install media)
                env["PATH"] = "/usr/lpp/X11/bin:#{ENV["PATH"]}"
                penv = env.dup
                penv["PATH"] = "/opt/freeware/bin:#{env['PATH']}"
                penv
              else
                env
              end

  if version.start_with? "1.0"
    patch source: "openssl-1.0.1f-do-not-build-docs.patch", env: patch_env
  elsif version.start_with? "1.1"
    patch source: "openssl-1.1.0f-do-not-install-docs.patch", env: patch_env
  end

  if version == "1.0.2k"
    patch source: "openssl-1.0.2k-no-bang.patch", env: patch_env, plevel: 1
  end

  if windows?
    # Patch Makefile.org to update the compiler flags/options table for mingw.
    patch source: "openssl-1.0.1q-fix-compiler-flags-table-for-msys.patch", env: env
  end

  # Out of abundance of caution, we put the feature flags first and then
  # the crazy platform specific compiler flags at the end.
  configure_args << env["CFLAGS"] << env["LDFLAGS"]

  configure_command = configure_args.unshift(configure_cmd).join(" ")

  command configure_command, env: env, in_msys_bash: true

  if windows?
    patch source: "openssl-1.0.1j-windows-relocate-dll.patch", env: env
  end

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
