module Validators
  class Rule

    NOT_UNIQ  = 'not_uniq'.freeze

    # todo or drop
    # NOT_FOUND = 'not_found'.freeze
    # INVALID   = 'invalid'.freeze
    # CONNECTION_ERROR = 'connection_error'.freeze
    # SYSTEM_ERROR     = 'system_error'.freeze

    attr_accessor :name

    def initialize(name)
      @name = name
    end


    class Unary < Validators::Rule
      attr_reader :value

      def initialize(name, value)
        super(name)
        @value = value
      end

    end


    class Binary < Validators::Rule
      attr_reader :left, :right

      def initialize(name, left, right)
        super(name)
        @left  = left
        @right = right
      end

    end


    class Composite < Validators::Rule::Binary

      def initialize(left, right)
        @left  = left
        @right = right
      end


      def add_error
        errors.merge!(left.errors)
        errors.merge!(right.errors) if right
      end

    end


    class And < Validators::Rule::Composite

      def valid?
        return true if left.valid? && right.valid?
        add_error
        false
      end

    end


    class Then < Validators::Rule::Composite

      def valid?
        return true unless left.valid?
        right.valid? ? true : (add_error; false)
      end

    end


    # noinspection RubyClassModuleNamingConvention
    class Or < Validators::Rule::Composite

      def valid?
        return true if left.valid? || right.valid?
        add_error
        false
      end

    end


    def errors
      @errors ||= Validators::Errors.new
    end


    def info
      {}
    end


    def add_error
      errors.add(name, reason, info)
    end


    def reason
      raise NotImplementedError
    end


    def valid?
      raise NotImplementedError
    end


    def and(rule)
      Validators::Rule::And.new(self, rule)
    end
    alias :& :and


    def then(rule)
      Validators::Rule::Then.new(self, rule)
    end
    alias :> :then

    def or(rule)
      Validators::Rule::Or.new(self, rule)
    end
    alias :| :or

  end
end
