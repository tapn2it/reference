#!/usr/bin/ruby -w
# placeholder.rb - use placeholders

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

#@ _INSERT_ROW_WITH_PLACEHOLDER_
  dbh.do("INSERT INTO people (id, name, height) VALUES(?, ?, ?)",
         nil, "Na'il", 76)
#@ _INSERT_ROW_WITH_PLACEHOLDER_

#@ _INSERT_FROM_FILE_
  # prepare statement for use within insert loop
  sth = dbh.prepare("INSERT INTO people (id, name, height) VALUES(?, ?, ?)")

  # read each line from file, split into values, and insert into database
  File.open("people.txt", "r") do |f|
    f.each_line do |line|
      name, height = line.chomp.split("\t")
      sth.execute(nil, name, height)
    end
  end
#@ _INSERT_FROM_FILE_

  # let's see what got inserted
  sth = dbh.execute("SELECT * FROM people")
  sth.fetch_array do |row|
    puts row.join(", ")
  end
  sth.finish

  # placeholders with SELECT statements
#@ _SELECT_PREPARE_
  sth = dbh.prepare("SELECT * FROM people WHERE name = ?")
  sth.execute("Na'il")
  sth.fetch do |row|
    printf "ID: %d, Name: %s, Height: %.1f\n", row[0], row[1], row[2]
  end
  sth.finish
#@ _SELECT_PREPARE_
#@ _SELECT_EXECUTE_
  sth = dbh.execute("SELECT * FROM people WHERE name = ?", "Na'il")
  sth.fetch do |row|
    printf "ID: %d, Name: %s, Height: %.1f\n", row[0], row[1], row[2]
  end
  sth.finish
#@ _SELECT_EXECUTE_
rescue DBI::DatabaseError => e
  puts "Error code: #{e.err}"
  puts "Error message: #{e.errstr}"
ensure
  dbh.disconnect if dbh
end
