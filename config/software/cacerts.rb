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

name "cacerts"

license "MPL-2.0"
license_file "https://github.com/bagder/ca-bundle/blob/master/README.md"

default_version "2016.01.20"

version "2016.01.20" do
  source md5: "36eee0e80373937dd90a9a334ae42817"
  source url: "https://raw.githubusercontent.com/bagder/ca-bundle/dfcc02c918b7bf40ed3a7f27a634c74ef4e80829/ca-bundle.crt"
end

version "2015.10.28" do
  source md5: "3c58c3f2435598a942dc37cdb02a3ec3"
  source url: "https://raw.githubusercontent.com/bagder/ca-bundle/86347ecbdc2277f365d02f0d208b822a214e012d/ca-bundle.crt"
end

relative_path "cacerts-#{version}"

build do
  mkdir "#{install_dir}/embedded/ssl/certs"

  # Append the 1024bit Verisign certs so that S3 continues to work
  block do
    unless File.foreach("#{project_dir}/ca-bundle.crt").grep(/^Verisign Class 3 Public Primary Certification Authority$/).any?
      File.open("#{project_dir}/ca-bundle.crt", "a") { |fd| fd.write(VERISIGN_CERTS) }
    end
  end

  copy "#{project_dir}/ca-bundle.crt", "#{install_dir}/embedded/ssl/certs/cacert.pem"

  # Windows does not support symlinks
  unless windows?
    link "#{install_dir}/embedded/ssl/certs/cacert.pem", "#{install_dir}/embedded/ssl/cert.pem"

    block { File.chmod(0644, "#{install_dir}/embedded/ssl/certs/cacert.pem") }
  end
end

VERISIGN_CERTS = <<-EOH

Verisign Class 3 Public Primary Certification Authority
=======================================================
-----BEGIN CERTIFICATE-----
MIICPDCCAaUCEHC65B0Q2Sk0tjjKewPMur8wDQYJKoZIhvcNAQECBQAwXzELMAkGA1UEBhMCVVMx
FzAVBgNVBAoTDlZlcmlTaWduLCBJbmMuMTcwNQYDVQQLEy5DbGFzcyAzIFB1YmxpYyBQcmltYXJ5
IENlcnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTk2MDEyOTAwMDAwMFoXDTI4MDgwMTIzNTk1OVow
XzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlTaWduLCBJbmMuMTcwNQYDVQQLEy5DbGFzcyAz
IFB1YmxpYyBQcmltYXJ5IENlcnRpZmljYXRpb24gQXV0aG9yaXR5MIGfMA0GCSqGSIb3DQEBAQUA
A4GNADCBiQKBgQDJXFme8huKARS0EN8EQNvjV69qRUCPhAwL0TPZ2RHP7gJYHyX3KqhEBarsAx94
f56TuZoAqiN91qyFomNFx3InzPRMxnVx0jnvT0Lwdd8KkMaOIG+YD/isI19wKTakyYbnsZogy1Ol
hec9vn2a/iRFM9x2Fe0PonFkTGUugWhFpwIDAQABMA0GCSqGSIb3DQEBAgUAA4GBALtMEivPLCYA
TxQT3ab7/AoRhIzzKBxnki98tsX63/Dolbwdj2wsqFHMc9ikwFPwTtYmwHYBV4GSXiHx0bH/59Ah
WM1pF+NEHJwZRDmJXNycAA9WjQKZ7aKQRUzkuxCkPfAyAw7xzvjoyVGM5mKf5p/AfbdynMk2Omuf
Tqj/ZA1k
-----END CERTIFICATE-----

Verisign Class 3 Public Primary Certification Authority
=======================================================
-----BEGIN CERTIFICATE-----
MIICPDCCAaUCEDyRMcsf9tAbDpq40ES/Er4wDQYJKoZIhvcNAQEFBQAwXzELMAkGA1UEBhMCVVMx
FzAVBgNVBAoTDlZlcmlTaWduLCBJbmMuMTcwNQYDVQQLEy5DbGFzcyAzIFB1YmxpYyBQcmltYXJ5
IENlcnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTk2MDEyOTAwMDAwMFoXDTI4MDgwMjIzNTk1OVow
XzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlTaWduLCBJbmMuMTcwNQYDVQQLEy5DbGFzcyAz
IFB1YmxpYyBQcmltYXJ5IENlcnRpZmljYXRpb24gQXV0aG9yaXR5MIGfMA0GCSqGSIb3DQEBAQUA
A4GNADCBiQKBgQDJXFme8huKARS0EN8EQNvjV69qRUCPhAwL0TPZ2RHP7gJYHyX3KqhEBarsAx94
f56TuZoAqiN91qyFomNFx3InzPRMxnVx0jnvT0Lwdd8KkMaOIG+YD/isI19wKTakyYbnsZogy1Ol
hec9vn2a/iRFM9x2Fe0PonFkTGUugWhFpwIDAQABMA0GCSqGSIb3DQEBBQUAA4GBABByUqkFFBky
CEHwxWsKzH4PIRnN5GfcX6kb5sroc50i2JhucwNhkcV8sEVAbkSdjbCxlnRhLQ2pRdKkkirWmnWX
bj9T/UWZYB2oK0z5XqcJ2HUw19JlYD1n1khVdWk/kfVIC0dpImmClr7JyDiGSnoscxlIaU5rfGW/
D/xwzoiQ
-----END CERTIFICATE-----
EOH
