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

name "ruby-windows"
default_version "1.9.3-p484"

relative_path "ruby-#{version}-i386-mingw32"

version "1.9.3-p484" do
  source md5: "a0665113aaeea83f1c4bea02fcf16694"
end

version "2.0.0-p451" do
  source md5: "37feadb0230e7f475a8591d1807ecfec"
end

version "2.1.3" do
  source md5: "60e39aaab140c3a22abdc04ec2017968"
end

source url: "http://dl.bintray.com/oneclick/rubyinstaller/ruby-#{version}-i386-mingw32.7z?direct"

build do

  sync "#{project_dir}/", "#{install_dir}/embedded"

  # Ruby 2.X dl.rb gives an annoying warning message on Windows:
  # DL is deprecated, please use Fiddle
  # Since we don't have patch on windows we are manually patching the file
  # to turn off the warning message
  # We are only removing dl.rb:8
  # => warn "DL is deprecated, please use Fiddle"
  if version.start_with? "2"
    block do
      require 'digest/md5'

      ABI_ver = version[/(^\d+\.\d+)/] + '.0'
      dl_path = File.join(install_dir, "embedded/lib/ruby", ABI_ver, "dl.rb")

      if Digest::MD5.hexdigest(File.read(dl_path)) == "78c185a3fcc7b5e2c3db697c85110d8f"
        File.open(dl_path, "w") do |f|
          f.print <<-E
  require 'dl.so'

  begin
    require 'fiddle' unless Object.const_defined?(:Fiddle)
  rescue LoadError
  end

  module DL
    # Returns true if DL is using Fiddle, the libffi wrapper.
    def self.fiddle?
      Object.const_defined?(:Fiddle)
    end
  end
  E
        end
      end
    end
  end
end
