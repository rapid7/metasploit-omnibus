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

## Building on Docker

The Dockerfiles for `metasploit-omnibus` are located within the `docker` directory of this repository.

You can build images yourself:

```shell
git clone https://github.com/rapid7/metasploit-omnibus.git
cd metasploit-omnibus
docker build --tag metasploit-omnibus-builder - < ./docker/kali109-x64/Dockerfile
```

You can then run a new container using the above tagged image, whilst mounting the current directory as a volume:

```shell
docker run -it --rm --volume $(pwd):$(pwd) --workdir $(pwd) --user jenkins metasploit-omnibus-builder /bin/bash --login
```

Or you can run a new container using pre-built images from [Rapid7's Docker Hub account](https://hub.docker.com/u/rapid7):

```shell
docker run -it --rm --volume $(pwd):$(pwd) --workdir $(pwd) --user jenkins rapid7/msf-kali109-x64-omnibus:2019_01 /bin/bash --login
```

By default, `metasploit-omnibus` will download the latest version of Metasploit framework from Github, but also supports building with local copies from `/metasploit-framework` - [full details](https://github.com/rapid7/metasploit-omnibus/blob/9cd575bcdd19d8fedf4a94c4ca2d1d6c253628c2/config/software/metasploit-framework.rb#L2-L8).

To build omnibus with a local version of Metasploit framework, you can mount your framework repository as a volume to `/metasploit-framework` within the container. The following command assumes that the repository exists within the parent directory:

```shell
docker run -it --rm --volume $(pwd):$(pwd) --volume=$(pwd)/../metasploit-framework:/metasploit-framework --workdir $(pwd) --user jenkins rapid7/msf-kali109-x64-omnibus:2019_01 /bin/bash --login
```

When running inside the container, you can perform a normal ommibus build:

```
# Download the git submodule that contains cached packages
git submodule update -i

# install omnibus' dependencies
bundle install --binstubs

# build the metasploit-framework package
bin/omnibus build metasploit-framework
```

When complete, there will be a new installable .deb file under the 'pkg' directory. Note that the use of Docker volumes may cause builds to run slower. 

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

## Building on Windows

From Windows 10, install ruby, msys2, ruby-devkit, wixtoolset, git. Add the following command to the the preparation steps before executing the `build` command.
```
xz -d local/cache/*.xz
``` 

## Building on OS X

From OS X, first install XCode and the command line development tools. I use ruby, bundler, git, bison and flex from the Mac Homebrew project. The rest of the steps are identical to building on Ubuntu. A .pkg file will be under the pkg directory instead.

## Clean

You can clean up all temporary files generated during the build process with
the `clean` command:

```shell
$ bin/omnibus clean metasploit-framework
```

Adding the `--purge` purge option removes __ALL__ files generated during the
build including the project install directory (`/opt/metasploit-framework`) and
the package cache directory (`/var/cache/omnibus/pkg`) as well as __ALL__ files
in the local package cache directory (`./local/cache`):

```shell
$ bin/omnibus clean metasploit-framework --purge
```

Restore the git submodule that contains the local package cache:
```shell
$ git submodule update -i
```

## Publish

Omnibus has a built-in mechanism for releasing to a variety of "backends", such
as Amazon S3. You must set the proper credentials in your `omnibus.rb` config
file or specify them via the command line.

```shell
$ bin/omnibus publish path/to/*.deb --backend s3
```

## Help

Full help for the Omnibus command line interface can be accessed with the
`help` command:

```shell
$ bin/omnibus help
```
