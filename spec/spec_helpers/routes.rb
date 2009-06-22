module SpecHelpers
  module Routes

    # example:
    #  it {should generate_route(:index, '/sales/customers/1/sales_orders', params = {:controller => @name, :customer_id => '1'})}
    class GenerateRoute
      def initialize(expected)
        @expected = expected
      end

      def matches?(controller)
        @actual = ::ActionController::Routing::Routes.generate(@expected[:params]) rescue nil
        @actual == @expected[:path]
      end

      def description
        "generate route for #{@expected[:params][:action].to_sym} with #{@actual.inspect}"
      end

      def failure_message
        "expected '#{@expected}' but got #{@actual}"
      end
      
      def negative_failure_message
        "unexpected '#{@expected}' but got #{@actual}"
      end
    end

    # example:
    # it {should recognize_route(:get, 'index', '/sales/customers/1/sales_orders', params = {:controller => 'sales/customers/sales_orders', :action => 'index', :customer_id => '1'})}
    class RecognizeRoute
      def initialize(expected)
        @expected = expected
      end
      
      def matches?(controller)
        @actual = ::ActionController::Routing::Routes.recognize_path(@expected[:path], :method => @expected[:method].to_sym)
        @actual == @expected[:params]
      end
      
      def description
        "recognize #{@expected[:params].inspect} from '#{@expected[:path]}', :method => #{@expected[:method].to_sym}"
      end

      def failure_message
        "expected '#{@expected[:params]}' but got '#{@actual.inspect}'"
      end

      def negative_failure_message
        "unexpected '#{@expected}' but got '#{@actual}'"
      end
    end

    # example:
    # it {should generate_and_recognize_route(:get, 'index', '/sales/customers/1/sales_orders', params = {:controller => 'sales/customers/sales_orders', :action => 'index', :customer_id => '1'})}
    class GenerateRecognizeRoute
      def initialize(expected)
        @expected = expected
      end

      def matches?(actual)
        @actual_route = ::ActionController::Routing::Routes.generate(@expected[:params]) rescue nil
        @actual_params = ::ActionController::Routing::Routes.recognize_path(@expected[:path], :method => @expected[:method].to_sym)
        @route_matches = @actual_route == @expected[:path]
        @params_match = @actual_params == @expected[:params]
        @route_matches && @params_match
      end

      def description
        %Q(generate and recognize route from #{@actual_params.inspect} and path: '#{@expected[:path]}' method: #{@expected[:method]})
      end

      def failure_message
        %Q(expected route for'#{@expected[:path]}' but got\n'#{@actual_route}'\n\n) unless @route_matches
        %Q(expected params from '#{@expected_params.inspect}' but got\n'#{@actual_params.inspect}\n\n') unless @params_match
      end

      def negative_failure_message
        %Q(unexpected route for'#{@expected[:path]}' but got\n'#{@actual_route}'\n\n) unless @route_matches
        %Q(unexpected params from '#{@expected[:params.inspect]}' but got\n'#{@actual_params.inspect}\n\n') unless @params_match
      end
    end

    # example:
    # it {should generate_and_recognize_default_routes({:controller => 'sales/customers/sales_orders', :path => '/sales/customers/1', :customer_id => '1'})}
    class GenerateRecognizeDefaultRoute
      def initialize(options)
        @expected = load_expected(options)
      end

      def matches?(controller)        
        @actual = {}
        @expected.each_key do |action|
          actual = {}
          actual[:route] = ::ActionController::Routing::Routes.generate(@expected[action][:params]) rescue nil
          actual[:params] = ::ActionController::Routing::Routes.recognize_path(@expected[action][:path], :method => @expected[action][:method].to_sym)
          actual[:route_matches] = actual[:route] == @expected[action][:path]
          actual[:params_match] = actual[:params] == @expected[action][:params]
          actual[:succcess] = actual[:route_matches] && actual[:params_match]
          @actual[action] = (actual)
        end
      end

      def description
        %Q(generate and recognize default routes for: #{@expected.keys.join(', ')})
      end

      def failure_message
        @expected.each_key do |action|
          %Q(expected route for'#{@expected[action][:path]}' but got\n'#{@actual[action][:route]}'\n\n) unless @actual[action][:route_matches]
          %Q(expected params from '#{@expected[action][:params].inspect}' but got\n'#{@actual[action][:params].inspect}\n\n') unless @actual[action][:params_match]
        end
      end

      def negative_failure_message
        @expected.each_key do |action|
          %Q(unexpected route for'#{@expected[action][:path]}' but got\n'#{@actual[action][:route]}'\n\n) if @actual[action][:route_matches]
          %Q(unexpected params from '#{@expected[action][:params].inspect}' but got\n'#{@actual[action][:params].inspect}\n\n') if @actual[action][:params_match]
        end
      end
      
      private

      def default_routes(path=nil, resource_name = nil)
        {
          :index   => [:get,    "#{path}/#{resource_name}",        {             }],
          :new     => [:get,    "#{path}/#{resource_name}/new",    {             }],
          :create  => [:post,   "#{path}/#{resource_name}",        {             }],
          :show    => [:get,    "#{path}/#{resource_name}/1",      { :id => '1' }],
          :edit    => [:get,    "#{path}/#{resource_name}/1/edit", { :id => '1' }],
          :update  => [:put,    "#{path}/#{resource_name}/1",      { :id => '1' }],
          :destroy => [:delete, "#{path}/#{resource_name}/1",      { :id => '1' }]
        }
      end

      def get_default_actions_to_check(options)
        actions = options[:only] || default_routes.keys
        actions = [actions] unless actions.is_a? Array

        except = options[:except] || []
        except = [except] unless except.is_a? Array
        options.merge!(options).delete :only
        options.merge!(options).delete :except
        actions.reject {|action| except.include?(action.to_s)}
      end
      
      def load_expected(options)
        actions = get_default_actions_to_check options
        routes = default_routes options[:path], options[:controller].split('/').last
        routes = routes.select {|action, params| actions.include? action}
        expected = {}
        routes.all? do |action, params|
          method, path, params = *params
          params.merge!({:action => action.to_s})
          params.merge!(options).delete :path
          expected[action] = {:method => method, :path => path, :params => params}
        end
        expected
      end
    end

    def generate_route(action, path, params={})
      params.merge!({:action => action.to_s})
      expected = {:path => path, :params => params}
      GenerateRoute.new(expected)
    end
    
    def recognize_route(method, path, params={})
      expected = {:method => method, :path => path, :params => params}
      RecognizeRoute.new(expected)
    end

    def generate_and_recognize_route(method, action, path, params={})
      expected = {:method => method, :action => action.to_s, :path => path, :params => params}
      GenerateRecognizeRoute.new(expected)
    end

    def generate_and_recognize_default_routes(options={})
      GenerateRecognizeDefaultRoute.new options
    end

  end
end