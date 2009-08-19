namespace :routes do
  desc 'Print out all defined routes in match order, with names.'
  task :paths => :environment do

#    Route: fulfillment/sales_channels
#    Route: destroy
#    Route: /fulfillment/companies/:company_id/sales_channels/:id(.:format)?
#      Route: {:controller=>"fulfillment/sales_channels", :action=>"destroy"}
#    Route: delete
#    Route: nil

    #    rts = ActionController::Routing::Routes.routes.reject do |rt|
    #      rt.defaults[:controller] != "fulfillment/sales_channels" || !rt.significant_keys.index(:id)
    #    end
    #    rts.each do |rt|
    ##      puts "Route: #{rt.inspect}"
    #      puts "Route: #{rt.defaults[:controller]}"
    #      puts "Route: #{rt.defaults[:action]}"
    #      puts "Route: #{rt.segments}"
    #      puts "Route: #{rt.requirements.inspect}"
    #      puts "Route: #{rt.conditions[:method]}"
    #      puts "Route: #{ActionController::Routing::Routes.named_routes.routes.index(rt).inspect}\n\n"
    #    end


    matcher = ENV['controller'].downcase
    puts "#{matcher}"
    routing = []
    ActionController::Routing::Routes.routes.each do |route|
      @path = ActionController::Routing::Routes.named_routes.routes.index(route).to_s
      @method = route.conditions[:method].to_s.upcase
      @segment = route.segments.inject("") { |str,s| str << s.to_s }
      @segment.chop! if @segment.length > 1

      @controller = route.requirements.empty? ? "" : route.requirements[:controller]
      @action = route.requirements.empty? ? "" : route.requirements[:action]

      route.requirements.delete :controller
      route.requirements.delete :action
      @requirements = route.requirements.empty? ? "" : route.requirements.inspect

      if @controller == "fulfillment/sales_channels"
        routing << [@controller, @action, @path, @method, @segment, @requirements]
      end
    end

    action_width = routing.collect {|controller, action, path, method, segment, requirements| action}.collect {|n| n ? n.length : 0}.max
    controller_width = routing.collect {|controller, action, path, method, segment, requirements| controller}.collect {|n| n ? n.length : 0}.max
    path_width = routing.collect {|controller, action, path, method, segment, requirements| path}.collect {|n| n ? n.length : 0}.max
    method_width = routing.collect {|controller, action, path, method, segment, requirements| method}.collect {|n| n ? n.length : 0}.max
    segment_width = routing.collect {|controller, action, path, method, segment, requirements| segment}.collect {|n| n ? n.length : 0}.max

    last_controller = ''
    routing.each do |controller, action, path, method, segment, requirements|

      #      puts route.inspect
      unless last_controller == controller
        puts "\n\ncontroller: '#{controller.ljust(controller_width)}'\n"
        puts "  segment: #{segment.ljust(segment_width)}\n\n"
      end

      puts "  #{action.ljust(action_width)}  #{method.ljust(method_width)}  #{path.ljust(path_width)}"
      last_controller = controller
    end

  end
end