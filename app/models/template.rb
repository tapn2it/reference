class Template < ActiveRecord::Base

  # organize methods for consistency
   
  # includes
  include SpecialPostMethods

  # validations
  validates_presence_of :title
  validates_uniqueness_of :slug

  # called class methods
  acts_as_textiled :body

  # relationships
  belongs_to :site
  has_many :comments

  # callbacks
  after_create :save_slug
  after_save :ping_technorati

  # named scopes
  named_scope :most_popular, :order => 'votes DESC'

  # class method definitions
  def self.post_types
    ['post', 'page']
  end

  # public method definitions
  def permalink
     
  end

private
  # private method definitions
  def flush_cache_entry

  end

  # callback method definitions
  def ping_technorati
     
  end

end