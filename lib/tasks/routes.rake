namespace :routes do

  desc 'Print out all defined routes in match order, with names.'
  task :paths => :environment do
    pattern = ENV['controller'] ? ENV['controller'].downcase : ''
    puts "Match on route controllers ~= #{pattern}"

    routes = routes_controller_methods_matched_to_app_controller_methods(pattern)
    action_width = routes.collect {|index, controller, action, path, method, segment, flag| action}.collect {|n| n ? n.length : 0}.max
    controller_width = routes.collect {|index, controller, action, path, segment, flag| controller}.collect {|n| n ? n.length : 0}.max
    path_width = routes.collect {|index, controller, action, path, method, segment, flag| path}.collect {|n| n ? n.length : 0}.max
    method_width = routes.collect {|index, controller, action, path, method, segment, flag| method}.collect {|n| n ? n.length : 0}.max
    segment_width = routes.collect {|index, controller, action, path, method, segment, flag| segment}.collect {|n| n ? n.length : 0}.max

    last_controller = ''
    routes.each do |index, controller, action, path, method, segment, in_app|
      unless last_controller == controller
        puts "\n\nCONTROLLER: #{controller.ljust(controller_width).strip}\n"
      end

      puts "  #{(in_app ? green(action) : yellow(action)).ljust(action_width+colorize_width)}  #{method.ljust(method_width)}  #{path.ljust(path_width)}"
      #      puts "    #{segment.ljust(segment_width)}"
      last_controller = controller
    end
  end

  desc 'Provides a list of controller methods found in routes and matches with app controller methods'
  task :test3 => :environment do
    total_count = 0
    no_route_count = 0
    controllers = routes_controller_methods_matched_to_app_controller_methods
    controllers.first(9).each {|a| puts a.inspect}
    controllers.each do |index, controller, action, path, method, segment, in_routes|
      if index and index != ':'
        total_count += 1
        no_route_count += 1 if in_routes
        puts in_routes ? yellow(index) : green(index)
      end
    end

    puts "\n\nNumber of routes controller methods: #{total_count}"
    puts green "Controller methods found in routes: #{total_count - no_route_count}"
    puts yellow "Controllers methods missing from routes: #{no_route_count}"
  end

  desc 'describe me'
  task :test4 => :environment do
    total_count = 0
    no_route_count = 0
    controllers = app_controller_methods_matched_to_controller_methods_in_routes
    controllers.each do |controller, in_routes|
      total_count += 1
      no_route_count += 1 unless in_routes
      puts in_routes ? green(controller) : yellow(controller)
    end

    puts "\n\nNumber of app controller methods: #{total_count}"
    puts green "Controller methods found in routes: #{total_count - no_route_count}"
    puts yellow "Controllers methods missing from routes: #{no_route_count}"
  end

  def list_directories(directory, pattern)
    result = []
    Dir.glob("#{directory}/*") do |file|
      next if file[0] == ?.
      if File.directory? file
        result.push(*list_directories(file, pattern))
      elsif file =~ pattern
        result << file
      end

    end
    result
  end

  def find_controllers_in_routes(pattern='')
    routes = []
    ActionController::Routing::Routes.routes.each do |route|
      path = ActionController::Routing::Routes.named_routes.routes.index(route).to_s
      method = route.conditions[:method].to_s.upcase
      segment = route.segments.inject("") { |str,s| str << s.to_s }
      segment.chop! if segment.length > 1
      controller = route.requirements.empty? ? "" : route.requirements[:controller]
      action = route.requirements.empty? ? "" : route.requirements[:action]
      route.requirements.delete :controller
      route.requirements.delete :action

      if controller =~ /#{pattern}/
        unless routes.assoc "#{controller}:#{action}"
          routes << ["#{controller}:#{action}", controller, action, path, method, segment]
        end
      end
    end
    routes
  end

  def find_controller_actions
    controller_actions = []
    controllers = list_directories "#{RAILS_ROOT}/app/controllers", /_controller.rb$/
    controllers.each {|a| a.gsub!("#{RAILS_ROOT}/app/controllers/",''); a.gsub!('.rb','')}
    controllers.each do |controller_path|
      controller = controller_path.camelize.gsub(".rb","")
      #      puts ">>>#{controller_path}"
      (eval("#{controller}.public_instance_methods") -
          ApplicationController.public_instance_methods -
          Object.methods).sort.each {|method| controller_actions << "#{controller.underscore.gsub!("_controller",'')}:#{method}"}
    end
    controller_actions
  end

  def app_controller_methods_matched_to_controller_methods_in_routes
    controllers = find_controller_actions
    routes = find_controllers_in_routes
    route_info = []
    controllers.each {|p| route_info << [p, routes.find {|i| i[0] == p }]}
    route_info
  end

  def routes_controller_methods_matched_to_app_controller_methods(pattern='')
    controllers = find_controller_actions
    routes = find_controllers_in_routes(pattern)
    routes.collect! {|p| p << controllers.find {|i| i == p[0] }}
  end

  def colorize(text, color_code)
    "#{color_code}#{text}\e[0m"
  end
  def colorize_width; 10;end
  def red(text); colorize(text, "\e[31m"); end
  def green(text); colorize(text, "\e[32m"); end
  def yellow(text); colorize(text, "\e[33m"); end

end