# frozen_string_literal: true

module Phlex
  module Preline
    # Provides validation methods for component parameters
    module Validatable
      extend ActiveSupport::Concern

      private

      # Validate that a value is present (not nil or empty)
      def validate_required!(value, name)
        raise MissingParameterError, "#{name} is required" if value.nil? || (value.respond_to?(:empty?) && value.empty?)

        value
      end

      # Validate that a value is included in allowed values
      def validate_inclusion!(value, name, allowed_values)
        return value if value.nil? # Allow nil for optional parameters

        raise InvalidParameterError, "Invalid #{name}: #{value}. Allowed values: #{allowed_values.join(', ')}" unless allowed_values.include?(value)

        value
      end

      # Validate that a value matches a pattern
      def validate_format!(value, name, pattern, message = nil)
        return value if value.nil?

        raise InvalidParameterError, message || "Invalid #{name} format: #{value}" unless value.to_s.match?(pattern)

        value
      end

      # Validate HTML ID format
      def validate_html_id!(id)
        return id if id.nil?

        # HTML ID must start with letter, followed by letters, digits, hyphens, underscores, colons, periods
        unless id.to_s.match?(/\A[a-zA-Z][\w\-:.]*\z/)
          raise InvalidParameterError,
                "Invalid HTML ID: #{id}. Must start with a letter and contain only letters, numbers, hyphens, underscores, colons, or periods."
        end

        id
      end

      # Validate CSS class names
      def validate_css_class!(class_name)
        return class_name if class_name.nil?

        # CSS class names should not contain special characters that could break CSS
        invalid_chars = /[<>"'&]/
        raise InvalidParameterError, "Invalid CSS class: #{class_name}. Contains invalid characters." if class_name.to_s.match?(invalid_chars)

        class_name
      end

      # Validate numeric values within range
      def validate_range!(value, name, min: nil, max: nil)
        return value if value.nil?

        numeric_value = value.to_i
        raise InvalidParameterError, "#{name} must be at least #{min}, got #{numeric_value}" if min && numeric_value < min
        raise InvalidParameterError, "#{name} must be at most #{max}, got #{numeric_value}" if max && numeric_value > max

        value
      end

      # Validate URL format
      def validate_url!(url, name = 'URL')
        return url if url.nil? || url == '#' # Allow anchor links

        begin
          parsed = URI.parse(url.to_s)
          # Allow HTTP(S), relative URLs, and common protocols like mailto: and tel:
          valid_schemes = %w[http https mailto tel]
          unless parsed.is_a?(URI::HTTP) || parsed.is_a?(URI::HTTPS) ||
                 parsed.relative? ||
                 (parsed.scheme && valid_schemes.include?(parsed.scheme))
            raise InvalidParameterError, "Invalid #{name}: must be HTTP(S), mailto, tel, or relative URL"
          end
        rescue URI::InvalidURIError
          raise InvalidParameterError, "Invalid #{name} format: #{url}"
        end
        url
      end

      # Validate URL format with XSS prevention
      def validate_url_strict(url, name = 'URL')
        return nil if url.nil?

        # Prevent javascript: and data: protocols
        raise InvalidParameterError, "#{name} contains potentially dangerous protocol" if url.to_s.match?(/\A\s*javascript:/i) || url.to_s.match?(/\A\s*data:/i)

        validate_url!(url, name)
      end

      # Validate email format
      def validate_email!(email, name = 'Email')
        return email if email.nil?

        email_pattern = /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i
        validate_format!(email, name, email_pattern, "Invalid email format: #{email}")
      end

      # Validate color format (hex, rgb, rgba, color names)
      def validate_color!(color, name = 'Color')
        return color if color.nil?

        hex_pattern = /\A#[0-9a-fA-F]{3}([0-9a-fA-F]{3})?\z/
        rgb_pattern = /\Argba?\(\s*\d{1,3}\s*,\s*\d{1,3}\s*,\s*\d{1,3}\s*(,\s*[\d.]+\s*)?\)\z/
        color_names = %w[red green blue yellow black white gray grey orange purple pink brown]

        unless color.to_s.match?(hex_pattern) ||
               color.to_s.match?(rgb_pattern) ||
               color_names.include?(color.to_s.downcase)
          raise InvalidParameterError, "Invalid #{name} format: #{color}"
        end

        color
      end

      # Type validation helpers
      def validate_string!(value, name)
        return value if value.nil? || value.is_a?(String)

        raise InvalidParameterError, "#{name} must be a string, got #{value.class}"
      end

      def validate_boolean!(value, name)
        return value if value.nil? || value.is_a?(TrueClass) || value.is_a?(FalseClass)

        raise InvalidParameterError, "#{name} must be a boolean, got #{value.class}"
      end

      def validate_integer!(value, name)
        return value if value.nil? || value.is_a?(Integer)

        raise InvalidParameterError, "#{name} must be an integer, got #{value.class}"
      end

      def validate_hash!(value, name)
        return value if value.nil? || value.is_a?(Hash)

        raise InvalidParameterError, "#{name} must be a hash, got #{value.class}"
      end

      def validate_array!(value, name)
        return value if value.nil? || value.is_a?(Array)

        raise InvalidParameterError, "#{name} must be an array, got #{value.class}"
      end

      # Validate a positive integer
      def validate_positive_integer!(value, name)
        return nil if value.nil?

        raise InvalidParameterError, "#{name} must be a positive integer" unless value.is_a?(Integer) && value.positive?

        value
      end

      # Validate tooltip delay value
      def validate_delay!(delay)
        return nil if delay.nil?

        if delay.is_a?(Integer) && delay >= 0
          delay
        elsif delay.is_a?(Hash)
          if delay.key?(:show) && !delay[:show].is_a?(Integer)
            raise InvalidParameterError,
                  'delay[:show] must be an integer'
          end
          if delay.key?(:hide) && !delay[:hide].is_a?(Integer)
            raise InvalidParameterError,
                  'delay[:hide] must be an integer'
          end

          delay
        else
          raise InvalidParameterError, 'delay must be a non-negative integer or hash with :show/:hide keys'
        end
      end
    end
  end
end
