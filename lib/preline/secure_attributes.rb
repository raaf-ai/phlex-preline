# frozen_string_literal: true

module Phlex
  module Preline
    # Provides secure attribute handling for components to prevent XSS and injection attacks
    module SecureAttributes
      extend ActiveSupport::Concern

      # Whitelist of allowed HTML attributes
      ALLOWED_HTML_ATTRIBUTES = %i[
        id class title lang dir tabindex
        placeholder disabled readonly required
        rows cols maxlength minlength pattern
        min max step size multiple checked
        autocomplete autofocus spellcheck
        rel target download
        alt src href width height loading
        type value name role
        colspan rowspan scope
        style
      ].freeze

      # Whitelist of allowed data attributes (without data- prefix)
      ALLOWED_DATA_ATTRIBUTES = %w[
        controller action target
        turbo turbo-frame turbo-permanent turbo-temporary
        dismiss-target toggle-target
        hs-alert hs-alert-close
        method track confirm remote
        section layout
      ].freeze

      # Whitelist of allowed ARIA attributes (without aria- prefix)
      ALLOWED_ARIA_ATTRIBUTES = %w[
        label labelledby describedby controls
        expanded hidden disabled checked pressed
        current level valuemin valuemax valuenow
        modal live atomic relevant busy
        haspopup owns flowto errormessage
      ].freeze

      private

      # Safely extract and sanitize HTML attributes from a hash
      # Note: This now works with attributes already extracted via grab()
      def extract_attributes(attrs)
        {
          custom_class: sanitize_value(@custom_class),
          html_attrs: sanitize_html_attributes(attrs),
          data_attrs: sanitize_data_attributes(@data_attrs),
          aria_attrs: sanitize_aria_attributes(@aria_attrs)
        }
      end

      # Sanitize standard HTML attributes
      def sanitize_html_attributes(attrs)
        attrs.slice(*ALLOWED_HTML_ATTRIBUTES).transform_values { |v| sanitize_value(v) }
      end

      # Sanitize data attributes
      def sanitize_data_attributes(data_attrs)
        return {} unless data_attrs.is_a?(Hash)

        data_attrs.select { |k, _| allowed_data_attribute?(k) }
                  .transform_values { |v| sanitize_value(v) }
      end

      # Sanitize ARIA attributes
      def sanitize_aria_attributes(aria_attrs)
        return {} unless aria_attrs.is_a?(Hash)

        aria_attrs.select { |k, _| allowed_aria_attribute?(k) }
                  .transform_values { |v| sanitize_value(v) }
      end

      # Check if a data attribute is allowed
      def allowed_data_attribute?(key)
        # Normalize key: remove data- prefix and convert underscores to dashes
        key = key.to_s.sub(/^data-/, '').gsub('_', '-')

        # Explicitly block dangerous attributes
        return false if key.match?(/^on\w+$/i) # Block onclick, onmouseover, etc.

        ALLOWED_DATA_ATTRIBUTES.include?(key) ||
          key.start_with?('turbo') || # Turbo/Hotwire attributes
          key.start_with?('bs-') || # Bootstrap data attributes
          key.start_with?('hs-') || # Preline/HyperScript data attributes
          key.match?(/^(test|id|value|custom|zoom|lightbox|gallery|modal)$/) || # Common test/demo attributes
          key.match?(/^(product|user|item|content)[-_](id|name|type|category)$/) # Common compound attributes
      end

      # Check if an ARIA attribute is allowed
      def allowed_aria_attribute?(key)
        key = key.to_s.sub(/^aria-/, '')
        ALLOWED_ARIA_ATTRIBUTES.include?(key)
      end

      # Sanitize attribute values to prevent XSS
      def sanitize_value(value)
        case value
        when String
          # Remove any potential script tags or javascript: URLs
          value.gsub(%r{<script.*?>.*?</script>}mi, '')
               .gsub(/javascript:/i, '')
               .gsub(/on\w+\s*=/i, '') # Remove event handlers
        when TrueClass, FalseClass
          # Convert boolean to string for HTML attributes
          value.to_s
        when Array
          value.map { |v| sanitize_value(v) }.join(' ')
        when Hash
          value.to_json # For complex data structures
        else
          value
        end
      end

      # Merge sanitized attributes into a single hash for HTML rendering
      def merge_attributes(extracted_attrs, additional_attrs = {})
        # Start with base HTML attributes
        base_attrs = extracted_attrs[:html_attrs].dup

        # Add data attributes with proper prefix
        extracted_attrs[:data_attrs].each do |k, v|
          # Convert underscores to dashes for HTML attributes
          base_attrs["data-#{k.to_s.gsub('_', '-')}"] = v
        end

        # Add aria attributes with proper prefix
        extracted_attrs[:aria_attrs].each do |k, v|
          base_attrs["aria-#{k}"] = v
        end

        # Handle class merging
        class_value = build_class_string(extracted_attrs[:custom_class], additional_attrs[:class])

        # Sanitize additional attributes before merging
        safe_additional_attrs = {}
        additional_attrs.each do |k, v|
          if k.to_s.start_with?('data-')
            key = k.to_s.sub(/^data-/, '')
            safe_additional_attrs[k] = sanitize_value(v) if allowed_data_attribute?(key)
          elsif k.to_s.start_with?('aria-')
            key = k.to_s.sub(/^aria-/, '')
            safe_additional_attrs[k] = sanitize_value(v) if allowed_aria_attribute?(key)
          elsif ALLOWED_HTML_ATTRIBUTES.include?(k.to_sym)
            safe_additional_attrs[k] = sanitize_value(v)
          end
        end

        # Use Phlex's mix helper to merge all attributes
        result = mix(base_attrs, safe_additional_attrs)
        result[:class] = class_value if class_value.present?

        result.compact
      end

      # Build class string from multiple sources
      def build_class_string(*classes)
        classes.flatten.compact.uniq.join(' ').presence
      end
    end
  end
end
