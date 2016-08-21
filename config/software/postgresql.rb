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

name "postgresql"
default_version "9.4.6"

license "PostgreSQL"
license_file "COPYRIGHT"

dependency "zlib"
dependency "openssl"
dependency "libedit"
dependency "ncurses"
dependency "libossp-uuid"
dependency "config_guess"

version "9.2.14" do
  source md5: "ce2e50565983a14995f5dbcd3c35b627"
end

version "9.2.10" do
  source md5: "7b81646e2eaf67598d719353bf6ee936"
end

version "9.2.9" do
  source md5: "38b0937c86d537d5044c599273066cfc"
end

version "9.2.8" do
  source md5: "c5c65a9b45ee53ead0b659be21ca1b97"
end

version "9.5.1" do
  source md5: "11e037afaa4bd0c90bb3c3d955e2b401"
end

version "9.5.0" do
  source md5: "2f3264612ac32e5abdfb643fec934036"
end

version "9.5beta1" do
  source md5: "4bd67bfa4dc148e3f9d09f6699b5931f"
end

version "9.4.6" do
  source md5: "0371b9d4fb995062c040ea5c3c1c971e"
end

version "9.4.5" do
  source md5: "8b2e3472a8dc786649b4d02d02e039a0"
end

version "9.4.1" do
  source md5: "2cf30f50099ff1109d0aa517408f8eff"
end

version "9.4.0" do
  source md5: "8cd6e33e1f8d4d2362c8c08bd0e8802b"
end

version "9.3.10" do
  source md5: "ec2365548d08f69c8023eddd4f2d1a28"
end

version "9.3.6" do
  source md5: "0212b03f2835fdd33126a2e70996be8e"
end

version "9.3.5" do
  source md5: "5059857c7d7e6ad83b6d55893a121b59"
end

version "9.3.4" do
  source md5: "d0a41f54c377b2d2fab4a003b0dac762"
end

version "9.1.15" do
  source md5: "6ac52cf13ecf6b09c7d42928d1219cae"
end

version "9.1.9" do
  source md5: "6b5ea53dde48fcd79acfc8c196b83535"
end

source url: "https://ftp.postgresql.org/pub/source/v#{version}/postgresql-#{version}.tar.bz2"

relative_path "postgresql-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  update_config_guess(target: "config")

  command "./configure" \
          " --prefix=#{install_dir}/embedded" \
          " --with-libedit-preferred" \
          " --with-openssl" \
          " --with-ossp-uuid" \
          " --with-includes=#{install_dir}/embedded/include" \
          " --with-libraries=#{install_dir}/embedded/lib", env: env

  make "world -j #{workers}", env: env
  make "install-world", env: env
end
