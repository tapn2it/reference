#!/usr/bin/ruby -w
# connect.rb - various ways of connecting

require "mysql"

begin
  puts "Connect using Mysql.real_connect"
#@ _WITH_REAL_CONNECT_
  dbh = Mysql.real_connect("localhost", "testuser", "testpass", "test")
#@ _WITH_REAL_CONNECT_
  puts "Connected"
  dbh.close
  puts "Disconnected"

  puts "Connect using Mysql.init + dbh.real_connect"
#@ _WITH_INIT_1_
  dbh = Mysql.init
  dbh.real_connect("localhost", "testuser", "testpass", "test")
#@ _WITH_INIT_1_
  puts "Connected"
  dbh.close
  puts "Disconnected"

  puts "Connect using Mysql.init + dbh.options + dbh.real_connect"
#@ _WITH_INIT_2_
  dbh = Mysql.init
  dbh.options(Mysql::READ_DEFAULT_GROUP, "client")
  dbh.real_connect
#@ _WITH_INIT_2_
  puts "Connected"
  dbh.close
  puts "Disconnected"

  puts "Connect using Mysql.real_connect and flags"
  # the following lines show two ways of combining flag values
  flags =
#@ _WITH_FLAGS_1_
    Mysql::CLIENT_COMPRESS | Mysql::CLIENT_INTERACTIVE
#@ _WITH_FLAGS_1_
  flags =
#@ _WITH_FLAGS_2_
    Mysql::CLIENT_COMPRESS + Mysql::CLIENT_INTERACTIVE
#@ _WITH_FLAGS_2_
  dbh = Mysql.real_connect("localhost", "testuser", "testpass", "test",
                           nil, nil, flags)
  puts "Connected"
  dbh.close
  puts "Disconnected"

rescue Mysql::Error => e
  puts "An error occurred"
  puts "Error code: #{e.errno}"
  puts "Error message: #{e.error}"
  puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
end
