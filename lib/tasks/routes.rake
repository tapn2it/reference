namespace :routes do
  desc 'Print out all defined routes in match order, with names.'
  task :path => :environment do
    routes = ActionController::Routing::Routes.routes.collect do |route|
      puts "route: #{route.inspect}"
      name = ActionController::Routing::Routes.named_routes.routes.index(route).to_s
      verb = route.conditions[:method].to_s.upcase
      segs = route.segments.inject("") { |str,s| str << s.to_s }
      segs.chop! if segs.length > 1
      
      controller = route.requirements.empty? ? "" : route.requirements[:controller]
      action = route.requirements.empty? ? "" : route.requirements[:action]
      route.requirements.delete :controller
      route.requirements.delete :action
      reqs = route.requirements.empty? ? "" : route.requirements.inspect
      [controller, action, {:name => name, :verb => verb, :segs => segs, :reqs => reqs}]
    end

    action_width = routes.collect {|controller, action, path| action}.collect {|n| n.length}.max
    last_controller = ''
    routes.each do |controller, action, path|
      unless last_controller == controller
        puts "\n\ncontroller: '#{controller}'"
      end
      puts "    action => :#{action.ljust(action_width)} #{path[:name]}"
      #      puts "    action => :#{action.ljust(action_width)} #{path[:segs]}"
      last_controller = controller
    end
  end
end