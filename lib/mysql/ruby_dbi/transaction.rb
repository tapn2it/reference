#!/usr/bin/ruby -w
# transaction.rb - demonstrate transaction support

require "dbi"

def setup_table(dbh)
  dbh.do("DROP TABLE IF EXISTS account")
  dbh.do("CREATE TABLE account (name CHAR(10), balance INT) TYPE=InnoDB")
  dbh.do("INSERT INTO account SET name='bill', balance=100")
  dbh.do("INSERT INTO account SET name='bob', balance=100")
end

def show_table(dbh)
  dbh.execute("SELECT name, balance FROM account") do |sth|
    sth.fetch do |row|
      puts "name: #{row[0]}, balance: #{row[1]}"
    end
  end
end

begin
  puts "Using commit/rollback methods:"
  dbh = DBI.connect("DBI:Mysql:test:localhost", "testuser", "testpass")
  puts "Before transaction:"
  setup_table(dbh)
  show_table(dbh)

  # perform transaction using explicit commit/rollback
#@ _COMMIT_ROLLBACK_METHODS_
  dbh['AutoCommit'] = false
  begin
    dbh.do("UPDATE account SET balance = balance - 50 WHERE name = 'bill'")
    dbh.do("UPDATE account SET balance = balance + 50 WHERE name = 'bob'")
    dbh.commit
  rescue
    puts "transaction failed"
    dbh.rollback
  end
  dbh['AutoCommit'] = true
#@ _COMMIT_ROLLBACK_METHODS_
  puts "After transaction:"
  show_table(dbh)

  puts ""
  puts "Using transaction method:"
  puts "Before transaction:"
  setup_table(dbh)
  show_table(dbh)

  # perform transaction using transaction method
#@ _TRANSACTION_METHOD_
  dbh['AutoCommit'] = false
  dbh.transaction do |dbh|
    dbh.do("UPDATE account SET balance = balance - 50 WHERE name = 'bill'")
    dbh.do("UPDATE account SET balance = balance + 50 WHERE name = 'bob'")
  end
  dbh['AutoCommit'] = true
#@ _TRANSACTION_METHOD_
  puts "After transaction:"
  show_table(dbh)
rescue DBI::DatabaseError => e
  puts "Error code: #{e.err}"
  puts "Error message: #{e.errstr}"
ensure
  dbh.disconnect if dbh
end
