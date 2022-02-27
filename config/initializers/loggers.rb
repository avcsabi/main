COMPANIES_HOUSE_LOGGER = Logger.new(Rails.root.join('log/companies_house.log'), 1, 10000000)
COMPANIES_HOUSE_LOGGER.formatter = proc do |severity, datetime, _, msg|
  "#{datetime.strftime('%Y-%m-%d %H:%M:%S')} #{severity}\n#{msg}\n"
end
