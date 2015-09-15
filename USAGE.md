# Using the metasploit-framework Omnibus package

Using the metasploit-framework omnibus package is simple. It is a native package that integrates well with your operating system, but does not depend on any packages outside of your base operating system. It also tries to avoid modifying or upgrading and system packages, so it should peacefully co-exist with the rest of your software.

## Quick Start

To quickly install the latest version of the metasploit-omnibus package, this one-liner will add the nightly build repository, import the Rapid7 GPG key and install the package:

```
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && chmod 755 msfinstall && ./msfinstall
```

After installing the package, you can simply run 'msfconsole' to start the Metasploit Framework console. An initial configuration script will then run, helping you configure the initial database and setup your PATH if desired. The out-of-box setup should look something like this:

```
$ msfconsole

 ** Welcome to Metasploit Framework Initial Setup **
    Please answer a few questions to get started.

Would you like to add msfconsole and other programs to your default PATH? y
You may need to start a new terminal or log in again for this to take effect.

Would you like to use and setup a new database (recommended)? y
Creating database at /Users/bcook/.msf4/db
Starting Postgresql
Creating database users
Creating initial database schema

 ** Metasploit Framework Initial Setup Complete **

[*] Starting the Metasploit Framework console...-[*] The initial module cache will be built in the background, this can take 2-5 minutes...
/

  Metasploit Park, System Security Interface
  Version 4.0.5, Alpha E
  Ready...
  > access security
  access: PERMISSION DENIED.
  > access security grid
  access: PERMISSION DENIED.
  > access main security grid
  access: PERMISSION DENIED....and...
  YOU DIDN'T SAY THE MAGIC WORD!
  YOU DIDN'T SAY THE MAGIC WORD!
  YOU DIDN'T SAY THE MAGIC WORD!
  YOU DIDN'T SAY THE MAGIC WORD!
  YOU DIDN'T SAY THE MAGIC WORD!
  YOU DIDN'T SAY THE MAGIC WORD!
  YOU DIDN'T SAY THE MAGIC WORD!


       =[ metasploit v4.11.0-dev [core:4.11.0.pre.dev api:1.0.0]]
+ -- --=[ 1454 exploits - 827 auxiliary - 229 post        ]
+ -- --=[ 376 payloads - 37 encoders - 8 nops             ]
+ -- --=[ Free Metasploit Pro trial: http://r-7.co/trymsp ]

msf >
```

## Post Installation Information

The main binaries are installed under /opt/metasploit-framework/bin. You can either add this to your PATH, or run directly, e.g. /opt/metasploit-framework/bin/msfconsole, or on Linux distributions, these will be linked directly to /usr/bin so you can run them straight away.

If you want to use the database and turned down automated setup, a wrapper script 'msfdb' will configure postgresql to run as your local user, storing the database under _~/.msf4/db/_. To enable the database, run _msfdb init_. This will start the database, and all other metasploit commands will then automatically start if as necessary.

```
$ msfdb
Manage a metasploit framework database

  msfdb init    # initialize the database
  msfdb reinit  # delete and reinitialize the database
  msfdb delete  # delete database and stop using it
  msfdb status  # check database status
  msfdb start   # start the database
  msfdb stop    # stop the database
```

_Note_
Running msfdb init will attempt to write a new database.yml file into your ~/.msf4 directory. You may want to remove or backup any pre-existing .msf4/database.yml file if you have already configured a database there.

If you want to build your own installer package or modify it, see the instructions here: https://github.com/rapid7/metasploit-omnibus

