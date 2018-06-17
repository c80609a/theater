module Validators
  class Attribute

    attr_reader :name, :value

    def initialize(name, value)
      @name  = name.to_s
      @value = value
    end


    def present?
      Validators::Rules::Present.new(name, value)
    end

    def max_length?(value)
      Validators::Rules::MaxLength.new(name, self.value, value)
    end

    def min_length?(value)
      Validators::Rules::MinLength.new(name, self.value, value)
    end

    def upcase
      @value = value.mb_chars.upcase rescue nil; self
    end

    def downcase
      @value = value.mb_chars.downcase rescue nil; self
    end

    def each(&block)
      rule = nil
      (value || []).each do |v|
        _attr = self.class.new(name, v)
        _rule = _attr.instance_eval &block
        rule  = rule ? rule & _rule : _rule
      end
      rule
    end

  end
end
