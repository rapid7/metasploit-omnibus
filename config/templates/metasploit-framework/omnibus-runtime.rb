require 'fileutils'
require 'securerandom'
require 'tempfile'

module OmnibusRailsRuntime
  def self.directory
    path = File.join(Msf::Config.config_directory, 'rails')
    FileUtils.mkdir_p(path, mode: 0700)
    stat = File.lstat(path)
    unless stat.directory? && stat.uid == Process.euid && (stat.mode & 0777) == 0700
      raise "Rails runtime directory must be owned by the current user and have mode 0700: #{path}"
    end
    path
  end

  private

  # Keep Rails' environment and credentials precedence; redirect only the
  # fallback that would otherwise write under the packaged application root.
  def generate_local_secret
    directory = OmnibusRailsRuntime.directory
    path = File.join(directory, 'local_secret.txt')
    unless File.exist?(path)
      Tempfile.create('local_secret', directory) do |file|
        file.write(SecureRandom.hex(64))
        file.close
        begin
          File.link(file.path, path)
        rescue Errno::EEXIST
          # Another startup has already published a complete secret.
        end
      end
    end
    File.binread(path)
  end
end

config = Metasploit::Framework::Application.config
config.singleton_class.prepend(OmnibusRailsRuntime)
if config.cache_store == [:file_store, "#{config.root}/tmp/cache/"]
  config.cache_store = [:file_store, File.join(OmnibusRailsRuntime.directory, 'cache')]
end
