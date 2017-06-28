metasploit-framework Omnibus project
==========================
This project creates full-stack platform-specific packages for
`metasploit-framework`. This is not the same as the Metasploit Community
edition. It only contains the framework command-line interface and the
associated tools and modules.

Installing the package
------------

If you just want to install this package, we provide a number of pre-built binaries for Metasploit that are rebuilt every night. See https://github.com/rapid7/metasploit-framework/wiki/Nightly-Installers for installation information.

Building the package
------------

## Prerequisites

This project has a package cache that should be pulled in before building. Run 'git submodule update -i' to download the git submodule that contains these packages. We cache these both for performance, and because occasionally upstream locations go away, and this allows the build to continue without broken dependencies.

## Building on Ubuntu / Debian systems
In general, a build environment needs a working C/C++ compiler, Ruby 1.9 or higher and the ruby development headers, bundler, git, bison and flex. A quad-core CPU and 4GB of ram are recommended.

The following steps should produce a successful build with Ubuntu and other Debian derivatives, starting from a fresh installation:
```shell
# install required packages to build on Ubuntu / Debian systems
sudo apt-get -y install build-essential git ruby bundler ruby-dev bison flex autoconf automake
```

Configure the omnibus cache and target directories if you want to build as non-root user (recommended).
```shell
# setup build directories you can write to
sudo mkdir -p /var/cache/omnibus
sudo mkdir -p /opt/metasploit-framework
sudo chown `whoami` /var/cache/omnibus
sudo chown `whoami` /opt/metasploit-framework
```

Next setup git if you need to.
```shell
# setup git (ignore if you already have it configured)
git config --global user.name "Nobody"
git config --global user.email "nobody@example.com"
```

Checkout the metasploit-framework installer builder and install omnibus' dependencies.
```shell
# checkout the builder repository
git clone https://github.com/rapid7/metasploit-omnibus.git
cd metasploit-omnibus
# install omnibus' dependencies
bundle install --binstubs
```

Finally, build the installer itself:
```shell
# build the metasploit-framework package
bin/omnibus build metasploit-framework
```
when complete, there will be a new installable .deb file under the 'pkg' directory.

## Building on OS X
From OS X, first install XCode and the command line development tools. I use ruby, bundler, git, bison and flex from the Mac Homebrew project. The rest of the steps are identical to building on Ubuntu. A .pkg file will be under the pkg directory instead.

### Clean

You can clean up all temporary files generated during the build process with
the `clean` command:

```shell
$ bin/omnibus clean metasploit-framework
```

Adding the `--purge` purge option removes __ALL__ files generated during the
build including the project install directory (`/opt/metasploit-framework`) and
the package cache directory (`/var/cache/omnibus/pkg`):

```shell
$ bin/omnibus clean metasploit-framework --purge
```

### Publish

Omnibus has a built-in mechanism for releasing to a variety of "backends", such
as Amazon S3. You must set the proper credentials in your `omnibus.rb` config
file or specify them via the command line.

```shell
$ bin/omnibus publish path/to/*.deb --backend s3
```

### Help

Full help for the Omnibus command line interface can be accessed with the
`help` command:

```shell
$ bin/omnibus help
```

Kitchen-based Build Environment
-------------------------------
Every Omnibus project ships will a project-specific
[Berksfile](http://berkshelf.com/) that will allow you to build your omnibus projects on all of the projects listed
in the `.kitchen.yml`. You can add/remove additional platforms as needed by
changing the list found in the `.kitchen.yml` `platforms` YAML stanza.

This build environment is designed to get you up-and-running quickly. However,
there is nothing that restricts you to building on other platforms. Simply use
the [omnibus cookbook](https://github.com/opscode-cookbooks/omnibus) to setup
your desired platform and execute the build steps listed above.

The default build environment requires Test Kitchen and VirtualBox for local
development. Test Kitchen also exposes the ability to provision instances using
various cloud providers like AWS, DigitalOcean, or OpenStack. For more
information, please see the [Test Kitchen documentation](http://kitchen.ci).

Once you have tweaked your `.kitchen.yml` (or `.kitchen.local.yml`) to your
liking, you can bring up an individual build environment using the `kitchen`
command.

```shell
$ bin/kitchen converge ubuntu-1204
```

Then login to the instance and build the project as described in the Usage
section:

```shell
$ bundle exec kitchen login ubuntu-1204
[vagrant@ubuntu...] $ cd metasploit-omnibus
[vagrant@ubuntu...] $ bundle install
[vagrant@ubuntu...] $ ...
[vagrant@ubuntu...] $ bin/omnibus build metasploit-framework
```

For a complete list of all commands and platforms, run `kitchen list` or
`kitchen help`.
