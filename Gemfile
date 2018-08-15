source 'https://rubygems.org'

# Install omnibus
# gem 'omnibus', '~> 4.0'
gem 'omnibus', git: 'https://github.com/rapid7/omnibus', branch: 'r7_working'

# Use Chef's software definitions. It is recommended that you write your own
# software definitions, but you can clone/fork Chef's to get you started.
# gem 'omnibus-software', github: 'opscode/omnibus-software'

# This development group is installed by default when you run `bundle install`,
# but if you are using Omnibus in a CI-based infrastructure, you do not need
# the Test Kitchen-based build lab. You can skip these unnecessary dependencies
# by running `bundle install --without development` to speed up build times.
group :development do
  # Use Berkshelf for resolving cookbook dependencies
  gem 'berkshelf', '~> 3.0'

  # Use Test Kitchen with Vagrant for converging the build environment
  gem 'test-kitchen'
  gem 'kitchen-vagrant'
  gem 'vagrant-wrapper'

  gem 'nio4r', '~> 1.2.1'
end
