module ViewHelper

  # helper method to generate rjs 
  def add_comment_to_form(options)
    update_page do |page|
      page.replace_html options[:comment_popup_id], ''
      page.insert_html :top, options[:comment_popup_id], '<a href="#" class="jqmClose">Close</a><hr />'
      page.insert_html :bottom, options[:comment_popup_id], :partial => '/comments/form', :locals => options.merge({:append_comment_function => options[:append_comment_function], :comment_form_id => options[:comment_form_id]})
      page.call("$().ready") do |p|
        p[options[:comment_popup_id].to_sym].jqm
      end
      page.call "$('##{options[:comment_popup_id]}').jqmShow"
    end
  end

end
