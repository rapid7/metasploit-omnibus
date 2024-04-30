name "metasploit-framework"
maintainer "Rapid7 Release Engineering <r7_re@rapid7.com>"
homepage "https://rapid7.com"

install_dir "#{default_root}/metasploit-framework"

# Version is extracted from the latest Git tag found in the local Git repository
build_version Omnibus::BuildVersion.semver + "-1rapid7"
build_iteration 1

if windows?
  dependency "metasploit-framework-wrappers-windows"
else
  dependency "metasploit-framework-wrappers"
end

exclude "**/.git"
exclude "**/bundler/git"

if mac_os_x?
  require_portable_links true
end

project_location_dir = name
package :msi do
  upgrade_code 'A3C83F57-6D8F-453A-9559-0D650A95EB21'
  wix_light_delay_validation true
  fast_msi true
  parameters ProjectLocationDir: project_location_dir
end

package :appx do
  skip_packager true
end
