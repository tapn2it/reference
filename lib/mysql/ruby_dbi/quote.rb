#!/usr/bin/ruby -w
# quote.rb - demonstrate quote method

require "dbi"

begin
  dbh = DBI.connect("DBI:Mysql:test:localhost", "testuser", "testpass")

  # create table
  dbh.do("DROP TABLE IF EXISTS people")
  dbh.do("CREATE TABLE people (
            id INT UNSIGNED NOT NULL AUTO_INCREMENT,
            name CHAR(20) NOT NULL,
            height FLOAT,
            PRIMARY KEY (id))")

#@ _GENERATE_INSERT_
  # read each line from file, split into values, and write INSERT statement
  File.open("people.txt", "r") do |f|
    f.each_line do |line|
      name, height = line.chomp.split("\t")
      printf "INSERT INTO people (id, name, height) VALUES(%s, %s, %s);\n",
             dbh.quote(nil), dbh.quote(name), dbh.quote(height)
    end
  end
#@ _GENERATE_INSERT_

rescue DBI::DatabaseError => e
  puts "Error code: #{e.err}"
  puts "Error message: #{e.errstr}"
ensure
  dbh.disconnect if dbh
end
