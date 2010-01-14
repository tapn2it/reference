#!/usr/bin/ruby -w
# func.rb - demonstrate use of func method to get at MySQL driver-specific
# thread_id and insert_id methods

require "dbi"

begin
  dbh = DBI.connect("DBI:Mysql:test:localhost", "testuser", "testpass")

  puts "stat: " + dbh.func(:stat).to_s
  puts "thread_id: " + dbh.func(:thread_id).to_s
  puts "host_info: " + dbh.func(:host_info).to_s
  puts "proto_info: " + dbh.func(:proto_info).to_s
  puts "server_info: " + dbh.func(:server_info).to_s
  puts "client_info: " + dbh.func(:client_info).to_s
  puts "client_version: " + dbh.func(:client_version).to_s
  # create and populate table
  dbh.do("DROP TABLE IF EXISTS people")
  dbh.do("CREATE TABLE people (
            id INT UNSIGNED NOT NULL AUTO_INCREMENT,
            name CHAR(20) NOT NULL,
            height FLOAT,
            PRIMARY KEY (id))")
  rows = dbh.do("INSERT INTO people (name,height)
                   VALUES
                     ('Wanda',62.5),
                     ('Robert',75),
                     ('Phillip',71.5),
                     ('Sarah',68)")
  puts "info: " + dbh.func(:info).to_s

  # add new row to table, then retrieve and display the AUTO_INCREMENT
  # value that is generated for it.
#@ _INSERT_ID_
  dbh.do("INSERT INTO people (name,height) VALUES('Mike',70.5)")
  id = dbh.func(:insert_id)
  puts "ID for new record: #{id}"
#@ _INSERT_ID_
rescue DBI::DatabaseError => e
  puts "Error code: #{e.err}"
  puts "Error message: #{e.errstr}"
ensure
  dbh.disconnect if dbh
end
