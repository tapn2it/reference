#!/usr/bin/ruby -w
# people.rb - demonstrate various DBI methods using people table

require "dbi"

begin
  dbh = DBI.connect("DBI:Mysql:test:localhost", "testuser", "testpass")
#@ _DO_
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
  puts "Number of rows inserted: #{rows}"
#@ _DO_

  puts "Fetch using standalone fetch calls"
#@ _FETCH_STANDALONE_
  sth = dbh.execute("SELECT * FROM people")
  while row = sth.fetch do
    printf "ID: %d, Name: %s, Height: %.1f\n", row[0], row[1], row[2]
  end
  sth.finish
#@ _FETCH_STANDALONE_

  puts "Fetch using fetch as iterator"
#@ _FETCH_ITERATOR_
  sth = dbh.execute("SELECT * FROM people")
  sth.fetch do |row|
    printf "ID: %d, Name: %s, Height: %.1f\n", row[0], row[1], row[2]
  end
  sth.finish
#@ _FETCH_ITERATOR_

  puts "Fetch using each as iterator"
#@ _EACH_ITERATOR_
  sth = dbh.execute("SELECT * FROM people")
  sth.each do |row|
    printf "ID: %d, Name: %s, Height: %.1f\n", row[0], row[1], row[2]
  end
  sth.finish
#@ _EACH_ITERATOR_

  puts "Fetch, accessing row values using each_with_name iterator"
  sth = dbh.execute("SELECT * FROM people")
  sth.each do |row|
#@ _EACH_WITH_NAME_ITERATOR_
    row.each_with_name do |val, name|
      printf "%s: %s, ", name, val.to_s
    end
    print "\n"
#@ _EACH_WITH_NAME_ITERATOR_
  end
  sth.finish

  puts "Fetch using standalone fetch_array calls"
#@ _FETCH_ARRAY_STANDALONE_
  sth = dbh.execute("SELECT * FROM people")
  while row = sth.fetch_array do
    printf "ID: %d, Name: %s, Height: %.1f\n", row[0], row[1], row[2]
  end
  sth.finish
#@ _FETCH_ARRAY_STANDALONE_

  puts "Fetch using fetch_array as iterator"
#@ _FETCH_ARRAY_ITERATOR_
  sth = dbh.execute("SELECT * FROM people")
  sth.fetch_array do |row|
    printf "ID: %d, Name: %s, Height: %.1f\n", row[0], row[1], row[2]
  end
  sth.finish
#@ _FETCH_ARRAY_ITERATOR_

  puts "Fetch using standalone fetch_hash calls"
#@ _FETCH_HASH_STANDALONE_
  sth = dbh.execute("SELECT * FROM people")
  while row = sth.fetch_hash do
    printf "ID: %d, Name: %s, Height: %.1f\n",
           row["id"], row["name"], row["height"]
  end
  sth.finish
#@ _FETCH_HASH_STANDALONE_

  puts "Fetch using fetch_hash as iterator"
#@ _FETCH_HASH_ITERATOR_
  sth = dbh.execute("SELECT * FROM people")
  sth.fetch_hash do |row|
    printf "ID: %d, Name: %s, Height: %.1f\n",
           row["id"], row["name"], row["height"]
  end
  sth.finish
#@ _FETCH_HASH_ITERATOR_

rescue DBI::DatabaseError => e
  puts "Error code: #{e.err}"
  puts "Error message: #{e.errstr}"
ensure
  dbh.disconnect if dbh
end

