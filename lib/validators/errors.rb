module Validators
  class Errors

    attr_reader :data

    def initialize
      @data = Hash.new { |hash, key| hash[key] = [] }
    end


    def add(key, reason, info = {}, path = nil)
      data[key.to_sym].delete_if { |details| details[:reason] == reason.to_s }
      data[key.to_sym] << { reason: reason.to_s, info: info, path: path }
      self
    end


    def merge!(other, prefix = nil)
      other.data.each do |key, errors|
        full_key = prefix.present? ? sprintf('%s.%s', prefix, key) : key
        errors.each { |details| add(full_key, details[:reason], details[:info], details[:path]) }
      end
      self
    end


    def key_present?(key)
      data.key?(key.to_sym)
    end


    def any?
      data.any?
    end


    def translate
      return unless data.present?
      result = Hash.new { |hash, key| hash[key] = [] }

      data.each do |key, errors|
        errors.each do |details|
          path      = sprintf('validation_errors.%s', (details[:path] || key))
          full_path = sprintf('%s.%s', path, details[:reason])
          if I18n.exists?(full_path)
            message = I18n.t(full_path, details[:info])
          elsif I18n.exists?(path) && I18n.t(path).is_a?(String)
            message = I18n.t(path, details[:info])
          else
            message = I18n.t(sprintf('validation_errors.%s', details[:reason]), details[:info])
          end

          result[key.to_sym] << message
        end
      end

      flat_keys_to_nested(result)
    end


    def nested_data
      flat_keys_to_nested(data)
    end


    private


    def flat_keys_to_nested(hash)
      hash.each_with_object({}) do |(key, value), all|
        key_parts = key.to_s.split('.').map!(&:to_sym)
        leaf = key_parts[0...-1].inject(all) { |h, k| h[k] ||= {} }
        leaf[key_parts.last] = value
      end
    end

  end
end
