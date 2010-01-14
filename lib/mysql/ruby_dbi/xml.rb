#!/usr/bin/ruby -w
# xml.rb - Try DBI::Utils::XMLFormatter module

require "dbi"

begin
  dbh = DBI.connect("DBI:Mysql:test:localhost", "testuser", "testpass")

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

#@ _XML_FORMATTER_TABLE_
  DBI::Utils::XMLFormatter.table(dbh.select_all("SELECT * FROM people"))
#@ _XML_FORMATTER_TABLE_

rescue DBI::DatabaseError => e
  puts "Error code: #{e.err}"
  puts "Error message: #{e.errstr}"
ensure
  dbh.disconnect if dbh
end

