#!/usr/bin/ruby -w
# text.rb - Try DBI::Utils::TableFormatter module

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

#@ _TABLE_FORMATTER_
  sth = dbh.execute("SELECT * FROM people")
  rows = sth.fetch_all
  col_names = sth.column_names
  sth.finish
  DBI::Utils::TableFormatter.ascii(col_names, rows)
#@ _TABLE_FORMATTER_
rescue DBI::DatabaseError => e
  puts "Error code: #{e.err}"
  puts "Error message: #{e.errstr}"
ensure
  dbh.disconnect if dbh
end
