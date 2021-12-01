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

name "bundler"

license "MIT"
license_file "https://raw.githubusercontent.com/bundler/bundler/master/LICENSE.md"
skip_transitive_dependency_licensing true

dependency "cacerts"
if windows?
  dependency "ruby-windows"
  dependency "rubygems"
else
  dependency "rubygems"
end

default_version "2.1.4"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  env['SSL_CERT_FILE'] = "#{install_dir}/embedded/ssl/cert.pem"

  v_opts = "--version '#{version}'" unless version.nil?
  gem [
    "install bundler",
    v_opts,
    "--force --no-document",
  ].compact.join(" "), env: env
end
