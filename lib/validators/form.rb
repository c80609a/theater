module Validators

  module Form

    extend ActiveSupport::Concern

    included do
      class_attribute :attribute_set
      class_attribute :rule_set
      self.attribute_set  = Set.new
      self.rule_set       = Set.new
    end

    CUSTOM_RULE     = 'custom_rule'.freeze
    COMPOSITE_RULE  = 'composite_rule'.freeze

    attr_reader :errors

    def initialize(attrs = {})
      @attributes = {}
      @errors     = ::Validators::Errors.new
      apply_defaults
      write_attributes(attrs)
    end


    def attributes
      attribute_set.inject({}) {|attrs, data| name = data[:name]; attrs[name] = @attributes[name]; attrs}
    end


    def write_attributes(attrs = {})
      attrs ||= {}
      attrs.each {|name, value| write_attribute(name, value)}
    end

    alias :attributes= :write_attributes


    def write_attribute(name, value)
      named = name.to_s
      return unless attribute_names.include?(named)
      type = attribute_set.select {|attribute| attribute[:name] == named}.first[:type]
      value = nil if value == ''
      # value = type == ::Boolean ? value.to_s.to_bool : type.evolve(value) # fixme:: mongoid dependency
      @attributes[named] = value
      value
    end

    alias :[]= :write_attribute


    def read_attribute(name)
      named = name.to_s
      return unless attribute_set.map {|attr| attr[:name]}.include?(named)
      attributes[named]
    end

    alias :[] :read_attribute


    def valid?
      rule_set.each do |data|
        case data[:type]
          when CUSTOM_RULE
            data[:attributes].map do |attr|
              attribute = Validators::Attribute.new(data[:name], attributes[attr])
              rule = attribute.instance_eval &data[:rule]
              errors.merge!(rule.errors) unless rule.valid?
            end
          when COMPOSITE_RULE
            attrs = data[:attributes].map do |attr|
              Validators::Attribute.new(data[:name], attributes[attr.to_s])
            end
            rule = data[:rule].call(*attrs)
            errors.merge!(rule.errors) unless rule.valid?
          else
        end
      end
      validate
      errors.data.blank?
    end


    def attribute_names
      attribute_set.map {|attr| attr[:name]}
    end


    private


    def validate
    end


    def apply_defaults
      attribute_set.each do |attribute|
        unless @attributes.key?(attribute[:name])
          write_attribute(attribute[:name], attribute[:default])
        end
      end
    end


    class_methods do


      def attribute_names
        attribute_set.map {|attr| attr[:name]}
      end


      private


      def attribute(name, type:, default: nil)
        named = name.to_s
        add_attribute(named, type, default)
        descendants.each do |subclass|
          subclass.add_attribute(named, type, default)
        end
      end


      def validates(*attributes, &block)
        attributes.each do |attribute|
          named = attribute.to_s
          add_rule(named, [named], CUSTOM_RULE, block)
          descendants.each do |subclass|
            subclass.add_rule(named, [named], block)
          end
        end
      end


      def rule(name, attributes, &block)
        named = name.to_s
        add_rule(named, attributes, COMPOSITE_RULE, block)
        descendants.each do |subclass|
          subclass.add_rule(named, attributes, block)
        end
      end


      def add_attribute(name, type, default)
        attribute = {name: name, type: type, default: default}
        attributes = attribute_set.dup.delete_if {|attr| attr[:name] == name}
        attributes << attribute
        self.attribute_set = attributes
        create_getter(name)
        create_setter(name)
        self
      end


      def add_rule(name, attributes, type, block)
        named = name.to_s
        self.rule_set << {name: named, rule: block, attributes: attributes, type: type}
        self
      end


      def create_getter(name)
        generated_methods.module_eval do
          n = "#{name}="
          undef_method(n) if method_defined?(n)
          define_method(n) {|value| write_attribute(n, value)}
        end
      end


      def create_setter(name)
        generated_methods.module_eval do
          n = "#{name}="
          undef_method(n) if method_defined?(n)
          define_method(n) {|value| write_attribute(n, value)}
        end
      end


      def generated_methods
        @generated_methods ||= begin
          mod = Module.new
          include(mod)
          mod
        end
      end


      # def re_define_method(name, &block)
      #   undef_method(name) if method_defined?(name)
      #   define_method(name, &block)
      # end

    end
  end

end