TEST_ROOT = File.realpath(File.join(File.dirname(__FILE__), 'data'))

Outback::Configuration.new 'test' do
  source :directory, "#{TEST_ROOT}/var/www" do
    exclude "#{TEST_ROOT}/var/www/foo"
    exclude "#{TEST_ROOT}/var/www/icons/*.png"
  end

=begin
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
=end

  processor :encryption do
    password 'very secure encryption password'
    
    # The default cipher is aes-256-cbc
    #cipher 'openssl supported cipher'
  end
=begin
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
=end  
  # SFTP storage
  target :sftp, 'localhost' do
    user 'backup'
    password 'password'
    #port 22
    ttl 1.day
    path '/backups/outback-test'
  end

  # Store on a local filesystem path
  target :directory, "#{TEST_ROOT}/backups/daily" do
    ttl   1.day
    directory_permissions 0700
    archive_permissions   0600
  end
end

Outback::Configuration.loaded.each do |configuration|
  Outback::Backup.new(configuration).run!
end
