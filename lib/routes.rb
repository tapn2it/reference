namespace :routes do

  desc 'Print out all defined routes in match order, with names.'
  task :by_routes_controller => :environment do
    task_setup "Attempting to match routes controller methods to app controller methods"
    methods = find_routes_controller_methods_matched_to_app_controller_methods(@pattern)
    index_width, controller_width, action_width, path_width, method_width, segment_width, app_controller_action = get_array_elements_max_width(methods)
    last_controller = ''
    methods.each do |index, controller, action, path, method, segment, app_controller_action|
      @methods_count += 1
      @missing_methods_count += 1 unless app_controller_action
      puts "\n\nCONTROLLER: #{controller.ljust(controller_width).strip}\n" unless last_controller == controller
      puts "  #{(app_controller_action ? green(action) : yellow(action)).ljust(action_width+colorize_width)}  #{method.ljust(method_width)}  #{path.ljust(path_width)}"
      last_controller = controller
    end
    display_counts
  end

  desc 'describe me'
  task :by_app_controller => :environment do
    task_setup "Attempting to match app controller methods found to routes controller methods"
    last_controller = ''
    find_app_controller_methods_matched_to_controller_methods_in_routes(@pattern).each do |controller, routes_controller_action|
      @methods_count += 1
      @missing_methods_count += 1 unless routes_controller_action
      controller_name, action = controller.split(':')
      puts "\n\nCONTROLLER: #{controller_name}\n" unless last_controller == controller_name
      puts "  #{routes_controller_action ? green(action) : yellow(action)}"
      last_controller = controller_name
    end
    display_counts
  end

  def get_array_elements_max_width(array)
    array.first.enum_with_index.map {|element,idx| array.map {|element| element[idx]}.map {|n| n ? n.length : 0}.max}
  end

  def task_setup(title)
    @pattern = ENV['pattern'] ? ENV['pattern'].downcase : ''
    @methods_count = 0
    @missing_methods_count = 0
    puts "\n#{title}\n\n"
    puts "Match controllers on pattern ~= /#{@pattern}/\n\n"
    puts green "Controller methods match"
    puts yellow "Controllers methods unmatched"
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

      if controller =~ /#{@pattern}/
        unless routes.assoc "#{controller}:#{action}"
          routes << ["#{controller}:#{action}", controller, action, path, method, segment]
        end
      end
    end
    routes
  end

  def find_controller_actions(pattern='')
    controller_actions = []
    controllers = list_directories "#{RAILS_ROOT}/app/controllers", /_controller.rb$/
    controllers.each {|a| a.gsub!("#{RAILS_ROOT}/app/controllers/",''); a.gsub!('.rb','')}
    controllers.each do |controller_path|
      if controller_path =~ /#{@pattern}/
        controller = controller_path.camelize.gsub(".rb","")
        (eval("#{controller}.public_instance_methods") -
            ApplicationController.public_instance_methods -
            Object.methods).sort.each {|method| controller_actions << ["#{controller.underscore.gsub!("_controller",'')}:#{method}"]}
      end
    end
    controller_actions
  end

  def find_app_controller_methods_matched_to_controller_methods_in_routes(pattern='')
    controllers_in_routes = find_controllers_in_routes(@pattern)
    find_controller_actions(@pattern).map! {|p| p << controllers_in_routes.find {|i| i[0] == p[0]}}
  end

  def find_routes_controller_methods_matched_to_app_controller_methods(pattern='')
    controller_actions = find_controller_actions(@pattern)
    find_controllers_in_routes(@pattern).map! {|p| p << controller_actions.find {|i| i[0] == p[0]}}
  end

  def display_counts
    puts "\n\nNumber of methods: #{@methods_count}"
    puts green "Controller methods matched: #{@methods_count - @missing_methods_count}"
    puts yellow "Controllers methods unmatched: #{@missing_methods_count}"
  end

  def colorize(text, color_code)
    "#{color_code}#{text}\e[0m"
  end
  def colorize_width; 10;end
  def red(text); colorize(text, "\e[31m"); end
  def green(text); colorize(text, "\e[32m"); end
  def yellow(text); colorize(text, "\e[33m"); end

end