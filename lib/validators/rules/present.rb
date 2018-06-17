module Validators
  module Rules
    class Present < Validators::Rule::Unary

      REASON = 'blank'.freeze

      def valid?
        return true if value.present?
        add_error
        false
      end


      def reason
        REASON
      end

    end
  end
end
