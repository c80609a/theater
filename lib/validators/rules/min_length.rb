module Validators
  module Rules
    class MinLength < Validators::Rule::Binary

      def valid?
        return true if left.size >= right
        add_error
        false
      end


      def reason
        'too_short'
      end


      def info
        { count: right }
      end

    end
  end
end
