module Serializers
  # поможет с форматированием данных, отдаваемых фронту
  module Formatter
    def format_date(date)
      date ? date.to_datetime.strftime('%d.%m.%Y') : date
    end
  end
end
