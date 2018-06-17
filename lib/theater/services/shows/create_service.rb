module Services
  module Shows
    # Добавит Спектакль.
    class CreateService

      attr_reader :show,      # Show < ActiveRecord::Base
                  :errors     # ::Validators::Errors

      def initialize
        _reset_attrs
      end

      def perform(params)
        # нужный вызов, если отлаживаемся в консоли
        _reset_attrs

        # уходим с ошибкой, если параметры некорректны
        form = Validators::Shows::CreateForm.new params
        unless form.valid?
          @errors.merge!(form.errors)
          return false
        end

        # если проверки прошли - пишем в базу
        @show = Show.new params
        @show.save!(validate: false)

        true
      end

      private

      # reset instance variables
      def _reset_attrs
        @show   = nil
        @errors = ::Validators::Errors.new
      end

    end
  end
end