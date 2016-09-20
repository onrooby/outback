Welcome to Outback
==================

Outback is a Ruby backup tool, enabling you to create backups of
your server files and databases and storing them in a local or
remote repository. Using a simple DSL, you can specify multiple
sources that generate backup data, as well as multiple targets,
where backups are going to be stored.

Outback configuration files are pure Ruby, so writing dynamic
configurations or even customized backup sources and targets is a
piece of cake.

Installation
------------
    $ gem install outback

Then you can invoke outback from the command line:

    $ outback --help

A simple configuration example
------------------------------

You can instantiate as many configurations as you like.
Outback will enqueue and execute all configurations that were
instantiated during a single run.

```` ruby
Outback::Configuration.new 'name' do
  source :directory, '/var/www' do
    exclude '/var/www/foo'
    exclude '/var/www/icons/*.png'
  end

  source :mysql do
    user 'mysqlusername'
    password 'mysqlpassword'
    host 'localhost'
    exclude 'mysql', 'information_schema'

    #
    # If you do not specify a specific database, all databases
    # will be dumped and included in the backup
    # database 'specific_database'  
  end

  processor :encryption do
    password 'very secure encryption password'
    
    # The default cipher is aes-256-cbc
    #cipher 'openssl supported cipher'
  end

  # Amazon S3 storage
  target :s3 do
    access_key  'S3 access key'
    secret_key  'S3 secret key'
    bucket_name 'bucketname'
    prefix      'backups/daily'

    # Backups will be purged after the time specified here.
    # Just omit the definition to keep archives forever.
    ttl         1.month
  end
  
  # SFTP storage
  target :sftp, 'example.com' do
    user 'backupuser'
    # Usually, SSH keys will be used to connect to the server.
    # Alternatively, a password can be given here.
    #password 'your password'

    # Default port is 22
    # port 1234
    ttl 1.day
    path '/backups'
  end

  # Store on a local filesystem path
  target :directory, '/media/backups/daily' do
    # If you specify the move option, archives will be moved from the temporary
    # filesystem location in order to speed up things. Otherwise, archives will
    # be copied. Note that a 'move'-to target must be specified last in the target
    # chain.
    move  true
    ttl   1.day
    user  'root'
    group 'root'
    directory_permissions 0700
    archive_permissions   0600
  end
end
````

Default configurations and commandline options
----------------------------------------------

If you place your backup configurations in the file `/etc/outback.conf` they
will be read automatically when the outback executable is invoked. Make
sure to have correct permissions on the configuration files, as they might
include database and encryption passwords.

Alternatively, you can pass in the configuration file to read as a
commandline argument. The default configuration file in /etc will then be
ignored:

    $ outback ./my_config.rb

If you have several backup configurations in a single file, say, for daily
and monthly backups, you can use the `-c` commandline option to select the
backup to be invoked:

    $ outback -c 'myservername-daily'

This will run only the backup with the specified name, which enables you to
write DRY configurations like this:

```` ruby
{ :daily => [14.days, 5.days], :monthly	=> [1.year, 1.year] }.each do |frequency, ttls|
  s3_ttl, directory_ttl = ttls

  Outback::Configuration.new "yourserver-#{frequency}" do
    source :directory, '/home'
    source :directory, '/var/svn'

    target :s3 do
      access_key  'foo'
      secret_key  'foo'
      bucket_name 'somebucket'
      prefix      "yourserver/#{frequency}"
      ttl         s3_ttl
    end

    target :directory, "/media/backups/#{frequency}" do
      move  true
      ttl   directory_ttl
      user  'root'
      group 'root'
      directory_permissions 0700
      archive_permissions   0600
    end
  end
end
````

Other commandline options are:

* `-v` `--verbose` be talky
* `-s` `--silent`  be silent
* `-t` `--test`    test configuration, then exit
* `-l` `--list`    list available configurations, then exit
* `-h` `--help`    display help
* `--version`      display version

Known Issues
------------

The s3 gem currently doesn't support V4 signatures, which are required for
s3 regions introduced after January 2014.
