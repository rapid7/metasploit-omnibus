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

name "openssl"

license "OpenSSL"
license_file "LICENSE"
skip_transitive_dependency_licensing true

dependency "cacerts"
dependency "openssl-fips" if fips_mode?

default_version "1.1.1f"

# OpenSSL source ships with broken symlinks which windows doesn't allow.
# Skip error checking.
source url: "https://www.openssl.org/source/openssl-#{version}.tar.gz", extract: :lax_tar

version("1.1.1f") { source sha256: "186c6bfe6ecfba7a5b48c47f8a1673d0f3b0e5ba2e25602dd23b629975da3f35" }
version("1.1.1d") { source sha256: "1e3a91bc1f9dfce01af26026f856e064eab4c8ee0a8f457b5ae30b40b8b711f2" }
version("1.1.0i") { source sha256: "ebbfc844a8c8cc0ea5dc10b86c9ce97f401837f3fa08c17b2cdadc118253cf99" }
version("1.1.0l") { source sha256: "74a2f756c64fd7386a29184dc0344f4831192d61dc2481a93a4c5dd727f41148" }
version("1.1.0h") { source sha256: "5835626cde9e99656585fc7aaa2302a73a7e1340bf8c14fd635a62c66802a517" }
version("1.0.2u") { source sha256: "ecd0c6ffb493dd06707d38b14bb4d8c2288bb7033735606569d8f90f89669d16" }
version("1.0.2t") { source sha256: "14cb464efe7ac6b54799b34456bd69558a749a4931ecfd9cf9f71d7881cac7bc" }
version("1.0.2s") { source sha256: "cabd5c9492825ce5bd23f3c3aeed6a97f8142f606d893df216411f07d1abab96" }
version("1.0.1u") { source sha256: "4312b4ca1215b6f2c97007503d80db80d5157f76f8f7d3febbe6b4c56ff26739" }
version("1.0.1t") { source sha256: "4a6ee491a2fdb22e519c76fdc2a628bb3cec12762cd456861d207996c8a07088" }
version("1.0.1s") { source sha256: "e7e81d82f3cd538ab0cdba494006d44aab9dd96b7f6233ce9971fb7c7916d511" }

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
    "no-comp",
    "no-idea",
    "no-mdc2",
    "no-rc5",
    "no-ssl2",
    "enable-ssl3",
    "no-zlib",
    "shared",
  ]

  configure_args += ["--with-fipsdir=#{install_dir}/embedded", "fips"] if fips_mode?

  configure_cmd =
    if aix?
      "perl ./Configure aix64-cc"
    elsif mac_os_x?
      "./Configure darwin64-x86_64-cc"
    elsif smartos?
      "/bin/bash ./Configure solaris64-x86_64-gcc -static-libgcc"
    elsif omnios?
      "/bin/bash ./Configure solaris-x86-gcc"
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
