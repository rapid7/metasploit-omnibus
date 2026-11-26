require 'securerandom'

config = Metasploit::Framework::Application.config
if config.cache_store == [:file_store, "#{config.root}/tmp/cache/"]
  config.cache_store = [:file_store, File.join(Msf::Config.config_directory, 'rails', 'cache')]
end

class << config
  private

  # Keep Rails' environment and credentials precedence, but replace its
  # tmp/local_secret.txt fallback with a key that only lives in this process.
  def generate_local_secret
    @omnibus_local_secret ||= SecureRandom.hex(64)
  end
end
