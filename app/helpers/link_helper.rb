module LinkHelper

  def link_to_new_window(name, options={}, html_options={})
    link_to link_text, options[:path], {:target => "_blank"}.merge(html_options)
  end
end
