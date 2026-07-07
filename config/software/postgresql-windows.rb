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

name "postgresql-windows"
default_version "16.14"

relative_path "pgsql"

if windows_arch_i386?
  raise "32-bit Windows is no longer supported"
else
  version "16.14" do
    source sha256: "f68c7fbd93029e60a4145ccb64337a32ddf02317a8194cb1f76e11557602642c"
  end

  source url: "http://get.enterprisedb.com/postgresql/postgresql-#{version}-1-windows-x64-binaries.zip"
end

build do

  copy "#{project_dir}/bin/*", "#{install_dir}/embedded/bin"
  copy "#{project_dir}/lib/*", "#{install_dir}/embedded/lib"
  # Remove OpenSSL import libraries and DLLs bundled by PostgreSQL.
  # PostgreSQL 16.x ships OpenSSL 3.0.x which lacks symbols (e.g. EVP_MD_CTX_get_size_ex)
  # that are present in MSYS2's OpenSSL 3.6.x headers. This causes:
  # 1. Linker errors: MinGW finds PostgreSQL's .lib before MSYS2's .dll.a
  # 2. Runtime LoadErrors: openssl.so calls symbols missing from the 3.0.x DLL
  # Replace with RubyInstaller's OpenSSL DLLs (3.6.x) which match the MSYS2 headers.
  delete "#{install_dir}/embedded/lib/libcrypto.lib"
  delete "#{install_dir}/embedded/lib/libssl.lib"
  delete "#{install_dir}/embedded/bin/libcrypto-3-x64.dll"
  delete "#{install_dir}/embedded/bin/libssl-3-x64.dll"
  block "Copy RubyInstaller OpenSSL DLLs to embedded/bin" do
    ruby_platform_dir = Dir.glob("#{install_dir}/embedded/lib/ruby/*/x64-mingw-ucrt").first
    raise "RubyInstaller platform dir not found under #{install_dir}/embedded/lib/ruby/" unless ruby_platform_dir
    %w[libcrypto-3-x64.dll libssl-3-x64.dll].each do |dll|
      src = File.join(ruby_platform_dir, dll)
      raise "RubyInstaller OpenSSL DLL not found: #{src}" unless File.exist?(src)
      FileUtils.cp(src, "#{install_dir}/embedded/bin/#{dll}")
    end
  end
  # Remove headers that conflict with other omnibus-bundled libraries before copying
  delete "#{project_dir}/include/libxml"
  delete "#{project_dir}/include/libxslt"
  delete "#{project_dir}/include/openssl"
  copy "#{project_dir}/include/*", "#{install_dir}/embedded/include"
  copy "#{project_dir}/share/*", "#{install_dir}/embedded/share"

end
