module ActiveRecord
  module StashInSerializedHash
    # example usage...
    #class Email < ActiveRecord::Base
    #  validates_presence_of :name, :phone, :email, :test, :orange
    #  serialize :data
    #
    #  stash :test, :oranges, :apple :in => :data
    #end
    extend ActiveSupport::Concern

    NO_TARGET_ERROR = "stashing needs a target serialized column. Supply an options hash with a :in key as the last argument (e.g. stash :apple, :in => :greeter)."

    included do
      class_inheritable_hash :stashed_attributes
      self.stashed_attributes = {}

      after_initialize :load_stashed_attributes
      before_save :stash_attributes
    end

    private
    def load_stashed_attributes
      stashed_attributes.each_pair do |store_name, methods|
        store = send(store_name)

        next unless store

        methods.each do |method|
          send :"#{method}=", store[method]
        end

      end
    end

    def stash_attributes
      stashed_attributes.each_pair do |store_name, methods|
        store = send(store_name)
        store ||= {}
        methods.each do |method|
          store[method] = send method
        end

      end
    end

    module ClassMethods

      def stash *methods
        options = methods.extract_options!
        options.assert_valid_keys(:in)
        options.symbolize_keys!

        unless serialized_column = options[:in]
          raise ArgumentError, NO_TARGET_ERROR
        end

        stashed_attributes[serialized_column] ||= []
        stashed_attributes[serialized_column] += methods.map(&:to_sym)
        attr_accessor *methods
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::StashInSerializedHash)
