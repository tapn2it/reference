#!/usr/bin/ruby -w
# data_sources.rb - exercise data_sources method

# The data_sources method makes no provision for specifying connection
# parameters and thus requires that you be able to connect using the
# default parameters.  Normally this means that you must be able to
# connect to the server without a password.

require "dbi"

require "mysql"

if ARGV.length == 1
  driver = ARGV[0]
else
  puts "Usage: drivers.rb driver_name"
  exit(1)
end

puts <<EOF
Ruby DBI data sources (this will fail unless you can connect w/o a password):
EOF

begin
  DBI::data_sources("DBI:" + driver).each do |name|
    puts name
  end
rescue DBI::DatabaseError => e
  puts "Error code: #{e.err}"
  puts "Error message: #{e.errstr}"
end

