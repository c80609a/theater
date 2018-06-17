module Validators
  module Rules
    class MaxLength < Validators::Rule::Binary

      REASON = 'too_long'.freeze

      def valid?
        return true if left.size <= right
        add_error
        false
      end


      def reason
        REASON
      end


      def info
        { count: right }
      end

    end
  end
end
