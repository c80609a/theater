# добавит возможность сериализации Спектакаля
module CanSerializeShow
  include Serializers::Formatter

  # @param [ActiveRecord::Base] show
  def serialize_show(show)
    # todo:: перенести в отдельный сериалайзер
    {
        id:       show.id,
        title:    show.title,
        start_at: format_date(show.start_at),
        stop_at:  format_date(show.stop_at)
    }
  end
end
