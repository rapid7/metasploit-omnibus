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

name "pcaprub"
default_version "0.13.3"

if windows?
  dependency "ruby-windows"
  dependency "ruby-windows-devkit"
  dependency "winpcap-devpack"
else
  dependency "ruby"
  dependency "libpcap"
end

dependency "cacerts"
dependency "rubygems"

build do
  # Skip pcaprub support for now as it causes compilation issues
  next if windows?

  env = with_standard_compiler_flags(with_embedded_path)
  env['SSL_CERT_FILE'] = "#{install_dir}/embedded/ssl/cert.pem"
  # Ignore:
  # pcaprub.c: In function 'rbpcap_each_data':
  # pcaprub.c:987:17: error: implicit declaration of function 'pcap_getevent'; did you mean 'pcap_geterr'? [-Wimplicit-function-declaration]
  #   987 |   fno = (HANDLE)pcap_getevent(rbp->pd);
  #       |                 ^~~~~~~~~~~~~
  #       |                 pcap_geterr
  # pcaprub.c:987:9: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
  #   987 |   fno = (HANDLE)pcap_getevent(rbp->pd);
  #       |         ^
  # pcaprub.c: In function 'rbpcap_each_packet':
  # pcaprub.c:1029:9: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
  #  1029 |   fno = (HANDLE)pcap_getevent(rbp->pd);
  cflags = "-Wno-int-to-pointer-cast -Wno-implicit-function-declaration"

  # Use version of pcaprub relative to the current directory if it exists
  local_pcaprub_checkout = File.expand_path(File.join(Dir.pwd, "..", "pcaprub"))
  command "echo checking for path: #{local_pcaprub_checkout}", env: env
  if File.exist?(local_pcaprub_checkout)
    gem "install --local #{local_pcaprub_checkout}/pkg/pcaprub-#{version}.gem", env: env
    command "echo after new pcaprub code", env: env
  else
    command "echo before old pcaprub code", env: env
    gem "install pcaprub" \
      " --version '#{version}' --no-document -- --with-cflags=\'#{cflags}\'", env: env
  end
end
