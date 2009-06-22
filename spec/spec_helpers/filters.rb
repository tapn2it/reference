# To change this template, choose Tools | Templates
# and open the template in the editor.
module SpecHelpers
  module Filters

    def before_filter(name)
      self.class.before_filter.detect { |f| f.method == name }
    end

    def run_filter(filter_method, params={})
      self.params = params
      instance_eval filter_method.to_s
    end

    def before_filters
      return self.class.before_filter.collect { |f| f.method }
    end

  end

  module BeforeFilters

    def has_options?(expected_options)
      expected_options.each do |key, values|
        expected_options[key] = Array(values).map(&:to_s).to_set
      end

      options == expected_options
    end

  end

end

ActionController::Base.send(:include, SpecHelpers::Filters)
ActionController::Filters::BeforeFilter.send(:include, SpecHelpers::BeforeFilters)
