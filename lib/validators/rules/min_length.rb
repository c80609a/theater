module Validators
  module Rules
    class MinLength < Validators::Rule::Binary

      REASON = 'too_short'.freeze

      def valid?
        return true if left.size >= right
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
