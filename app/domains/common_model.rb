module CommonModel
  def self.all_except_excluded(text, options={})
    conditions = text.blank? ? [] : [options[:columns].map{|c| "#{c} LIKE :term"}.join(' OR '), {:term => "%#{text}%"}]
    conditions << options[:excluded_ids].blank? ? [] : %Q(ID NOT IN (#{options[:excluded_ids].join(',')}))
    conditions.join(' AND ')
    all :conditions => conditions, :order => options[:order]
  end

  def self.all_except_excluded(text, options={})
    conditions = text.blank? ? [] : [options[:columns].map{|c| "#{c} LIKE :term"}.join(' OR '), {:term => "%#{text}%"}]
    conditions << (options[:excluded_ids].blank? ? [] : ["ID NOT IN (#{options[:excluded_ids].join(',')})"])
    all :conditions => conditions.join(' AND '), :order => options[:order]
  end
end