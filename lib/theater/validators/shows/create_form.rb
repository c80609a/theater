module Validators
  module Shows
    # проверит корректность входящих данных для создания Спектакля.
    class CreateForm
      include Validators::Form

      REASON_OVERLAP = 'period_overlap'.freeze

      attribute :title,       type: String
      attribute :start_at,    type: Date
      attribute :stop_at,     type: Date

      # стандартные проверки
      validates(:title)       { present? & max_length?(255) & min_length?(5) }
      validates(:start_at)    { present? }
      validates(:stop_at)     { present? }

      def initialize(attrs = {})
        super attrs
      end

      # кастомные проверки
      def validate
        validate_title_uniq
        validate_overlaps
      end

      private

      # вернёт false, если в базе уже есть спектакль с таким title
      def validate_title_uniq
        # не проверяем уникальность, если уже есть ошибки проверки title
        return if errors.key_present? :title

        # средствами ActiveRecord попытаемся найти в базе Спектакль с таким же именем
        show = Show.find_by :title => @attributes['title']
        unless show.nil?
          @errors.add(:title, ::Validators::Rule::NOT_UNIQ)
          return false
        end

        true
      end

      # вернёт false, если добавляемый Спектакль "наслаивается" на уже имеющиеся в базе
      def validate_overlaps
        return if errors.key_present? :title

        detector   = ::Services::Shows::OverlapDetector.new
        is_overlap = detector.perform @attributes['start_at'], @attributes['stop_at']
        if is_overlap
          @errors.add(:time, REASON_OVERLAP)
          return false
        end

        true
      end

    end

  end

end
