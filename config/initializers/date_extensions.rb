module ActiveSupport::CoreExtensions::Numeric::Time
  def business_days_ago_from_now(interval=0)
    business_days = 0
    total_days = 0
    while business_days < interval
      total_days+=1
      business_days +=1 unless [0, 6].include?(total_days.days.ago.wday)
    end
    total_days.days.ago
  end
end