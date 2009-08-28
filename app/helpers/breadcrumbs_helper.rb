module BreadcrumbsHelper
  # Append one or more crumbs
  def drop_crumbs(*args)
    @breadcrumbs ||= []
    #    args = [request.path] if args.empty?
    args = ["/sales/brokers/Ca1/customers/1/customer_documents/3"] if args.empty?
    args.each do |crumb|
      crumbs = make_crumb(crumb)
      if crumbs[0].instance_of? Array
        @breadcrumbs = @breadcrumbs | crumbs
      else
        @breadcrumbs << crumbs
      end
    end
  end

  private

  # Returns a crumb array like ['Home', '/']
  def make_crumb(crumb)
    return ['Home', '/'] if crumb.empty?
    if crumb.instance_of? String
      break_off_crumbs(crumb)
    elsif crumb.instance_of? Array
      return crumb if crumb.size > 1
      return ['Home', '/'] if crumb[0].empty?
      title = crumb[0].split('/').last.split(/_|\s/).each { |word| word.capitalize! }.join(' ') unless crumb[0].nil?
      [title, crumb[0]]
    end
  end

  # Break a uri into an array of crumbs
  def break_off_crumbs(uri)
    crumbs = []
    split_uri = uri.split('/')
    split_uri.each_with_index do |crumb, i|
      crumbs << make_crumb([split_uri[0..i].join('/')])
    end
    crumbs
  end
end
