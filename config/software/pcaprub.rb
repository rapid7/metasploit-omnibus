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
default_version "0.13.1"

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
  env = with_standard_compiler_flags(with_embedded_path)
  env['SSL_CERT_FILE'] = "#{install_dir}/embedded/ssl/cert.pem"

  # We need to create the pcaprub gem ourselves until 0.13.2 is released (https://github.com/pcaprub/pcaprub/issues/67)
  # Use version of pcaprub relative to the current directory
  local_pcaprub_checkout = File.expand_path(File.join(Dir.pwd, "..", "pcaprub"))
  command "echo checking for path: #{local_pcaprub_checkout}", env: env
  if File.exist?(local_pcaprub_checkout)
    gem "install --local #{local_pcaprub_checkout}/pkg/pcaprub-#{version}.gem", env: env
    command "echo after new pcaprub code", env: env
  else
    command "echo before old pcaprub code", env: env
    gem "install pcaprub" \
      " --version '#{version}' --no-document", env: env
  end
end
