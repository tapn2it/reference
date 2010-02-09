# a simple/configurable rake task that generates some random fake data for the app (using faker) at various sizes
# NOTE: requires the faker gem - http://faker.rubyforge.org - sudo gem install faker

require 'faker'

class Fakeout

  # START Customizing

  # 1. first these are the model names we're going to fake out, note in this example, we don't create tags/taggings specifically
  # but they are defined here so they get wiped on the clean operation
  # e.g. this example fakes out, Users, Questions and Answers, and in doing so fakes some Tags/Taggings
  MODELS = %w(User Question Answer Tag Tagging)

  # 2. now define a build method for each model, returning a list of attributes for Model.create! calls
  # check out the very excellent faker gem rdoc for faking out anything from emails, to full addresses; http://faker.rubyforge.org/rdoc
  # NOTE: a build_??? method MUST exist for each model you specify above
  def build_user(username = "#{Faker::Internet.user_name}_#{random_letters}", email = Faker::Internet.email, password = 'password')
    { :username              => username,
      :email                 => email,
      :password              => password,
      :password_confirmation => password }
  end

  # in this example i'm faking out time - like Marty McFly!
  def build_question
    question_time = fake_time_from(1.year.ago)

    { :title            => "#{Faker::Lorem.sentence(8+rand(8)).chop}?",
      :information      => Faker::Lorem.paragraph(rand(3)),
      :tag_list         => random_tag_list(all_tags),
      :notify_user      => false,
      :created_at       => question_time,
      :updated_at       => question_time,
      :spam_answer      => '2',
      :spam_question    => '1+1 is?',
      :possible_answers => [Digest::MD5.hexdigest('2')],
      :user             => pick_random(User, true) }
  end

  # in this example i'm faking out time again! - this time to be after the question's created at time
  def build_answer
    question    = pick_random(Question)
    answer_time = question.created_at+rand(168).hours

    { :title            => Faker::Lorem.paragraph(1+rand(4)),
      :question         => question,
      :created_at       => answer_time,
      :updated_at       => answer_time,
      :user             => pick_random(User, true),
      :spam_answer      => '2',
      :spam_question    => '1+1 is?',
      :possible_answers => [Digest::MD5.hexdigest('2')],
    }
  end

  # return nil, or an empty hash for models you don't want to be faked out on create, but DO want to be clearer away
  def build_tag; end

  def build_tagging; end

  # called after faking out, use for additional updates or additions
  def post_fake
    User.create!(build_user('matt', 'matt@hiddenloop.com', 'hansolo1'))
    User.update_all('email_confirmed = 1')
  end

  # 3. disable any mailers that you might have in your app!, just leave blank if none
  def self.disable_mailers
    NotifierMailer.perform_deliveries = false
  end

  # 4. optionally you can change these numbers, basically they are used to determine the number of models to create
  # and also the size of the tags array to choose from.  To check things work quickly use the tiny size (1 for everything)
  def tiny
    1
  end

  def small
    25+rand(50)
  end

  def medium
    250+rand(250)
  end

  def large
    1000+rand(500)
  end

  # END Customizing

  attr_accessor :all_tags, :size

  def initialize(size)
    self.size     = size
    self.all_tags = Faker::Lorem.words(send(size))
  end

  def fakeout
    puts "Faking it ... (#{size})"
    Fakeout.disable_mailers
    MODELS.each do |model|
      if !respond_to?("build_#{model.downcase}")
        puts "  * #{model.pluralize}: **warning** I couldn't find a build_#{model.downcase} method"
        next
      end
      1.upto(send(size)) do
        attributes = send("build_#{model.downcase}")
        model.constantize.create!(attributes) if attributes && !attributes.empty?
      end
      puts "  * #{model.pluralize}: #{model.constantize.count(:all)}"
    end
    post_fake
    puts "Done, I Faked it!"
  end

  def self.clean
    puts "Really? This will clean all #{MODELS.map(&:pluralize).join(', ')} from your #{RAILS_ENV} database y/n? "
    STDOUT.flush
    if STDIN.gets =~ /^y|^Y/
      puts "Cleaning all ..."
      Fakeout.disable_mailers
      MODELS.each do |model|
        model.constantize.delete_all
      end
    end
  end


  private
  # pick a random model from the db, done this way to avoid differences in mySQL rand() and postgres random()
  def pick_random(model, optional = false)
    return nil if optional && (rand(2) > 0)
    ids = ActiveRecord::Base.connection.select_all("SELECT id FROM #{model.to_s.tableize}")
    model.find(ids[rand(ids.length)]["id"].to_i) unless ids.blank?
  end

  # useful for prepending to a string for getting a more unique string
  def random_letters(length = 2)
    Array.new(length) { (rand(122-97) + 97).chr }.join
  end

  # pick a random number of tags up to max_tags, from an array of words, join the result with seperator
  def random_tag_list(tags, max_tags = 5, seperator = ',')
    start = rand(tags.length)
    return '' if start < 1
    tags[start..(start+rand(max_tags))].join(seperator)
  end

  # fake a time from: time ago + 1-8770 (a year) hours after
  def fake_time_from(time_ago = 1.year.ago)
    time_ago+(rand(8770)).hours
  end
end


# the tasks, hook to class above
namespace :fakeout do

  desc "clean away all data"
  task :clean => :environment do
    Fakeout.clean
  end

  desc "fake out a tiny dataset"
  task :tiny => :clean do
    Fakeout.new(:tiny).fakeout
  end

  desc "fake out a small dataset"
  task :small => :clean do
    Fakeout.new(:small).fakeout
  end

  desc "fake out a medium dataset"
  task :medium => :clean do
    Fakeout.new(:medium).fakeout
  end

  desc "fake out a large dataset"
  task :large => :clean do
    Fakeout.new(:large).fakeout
  end
end