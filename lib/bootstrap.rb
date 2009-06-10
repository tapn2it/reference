module Bootstrap
  require 'yaml'
  require File.dirname(__FILE__) + '/../config/environment'
  require 'active_record/fixtures'

  class << self
    def all
      puts "DB bootstrap table loads in progress"
      self.load_lookups
      puts "\nDB boot strapped!\n\n"
    end

    def lookups
      self.load_lookups
    end
    protected

    def load_lookups
      puts 'Delete all & load lookups table...'
      Lookup.delete_all
      ActiveRecord::Base.connection.execute("ALTER TABLE lookups AUTO_INCREMENT = 1;")
      lookups = CSV.open("#{Dir.getwd}/db/data/lookups.csv", 'r')
      #TODO vc need to handle first row with headers
      lookups.each do |row|
        Lookup.create(:description => row[0], :lookupable_type => row[1], :lookupable_column => row[2])
      end
    end
  end
end
