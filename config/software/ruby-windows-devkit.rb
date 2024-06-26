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

name "ruby-windows-devkit"

license "BSD-3-Clause"
license_file "https://raw.githubusercontent.com/oneclick/rubyinstaller/master/LICENSE.txt"
skip_transitive_dependency_licensing true

dependency "ruby-windows-msys2"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  embedded_dir = "#{install_dir}/embedded"

  # Ruby Installer for windows:
  # 1 - MSYS2 base installation
  # 2 - MSYS2 system update (optional)
  # 3 - MSYS2 and MINGW development toolchain
  command "#{embedded_dir}/bin/ridk.cmd install 2 3", env: env, cwd: embedded_dir
end
