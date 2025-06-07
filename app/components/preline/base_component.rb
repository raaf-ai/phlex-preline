# frozen_string_literal: true

module Components
  extend ::Phlex::Kit

  module Preline
    class BaseComponent < ::Phlex::HTML
      include ::Phlex::Helpers

      if defined?(::Phlex::Rails)
        include ::Phlex::Rails::Helpers::Routes
        include ::Phlex::Rails::Helpers::FormWith
        include ::Phlex::Rails::Helpers::LinkTo
        include ::Phlex::Rails::Helpers::ButtonTag
        include ::Phlex::Rails::Helpers::Pluralize
        include ::Phlex::Rails::Helpers::OptionsForSelect
        include ::Phlex::Rails::Helpers::Truncate
        include ::Phlex::Rails::Helpers::T
        include ::Phlex::Rails::Helpers::URLFor
      end

      # Include security and validation concerns
      include ::Phlex::Preline::SecureAttributes
      include ::Phlex::Preline::Validatable

      # Wrap the around_template callback to add component identification in development
      def around_template
        if defined?(Rails) && Rails.env.development?
          comment { "BEGIN #{self.class.name}" }
          super
          comment { "END #{self.class.name}" }
        else
          super
        end
      rescue StandardError => e
        # Re-raise in test environment to see the actual error
        raise e if defined?(Rails) && Rails.env.test?

        handle_render_error(e)
      end

      def code_path(path)
        return unless defined?(Rails) && Rails.env.local?

        comment { "Codepath: #{path} executed" }
      end

      private

      # Common initialization pattern for components
      def initialize_component(attrs = {})
        @custom_class = attrs.delete(:class)
        @data_attrs = attrs.delete(:data) || {}
        @aria_attrs = attrs.delete(:aria) || {}
        @id = attrs.delete(:id)

        # Store sanitized attributes
        @extracted_attrs = extract_attributes(attrs)
      end

      # Get merged attributes for rendering using Phlex 2.0 mix pattern
      def component_attributes(additional_classes: nil, additional_attrs: {})
        # Use the merge_attributes method from SecureAttributes
        # which already handles sanitization
        base_attrs = merge_attributes(@extracted_attrs, additional_attrs)

        # Add additional classes if provided
        if additional_classes.present?
          existing_classes = base_attrs[:class]
          base_attrs[:class] = [existing_classes, additional_classes].compact.join(' ').presence
        end

        # Add ID if provided (sanitized)
        base_attrs[:id] = sanitize_value(@id) if @id.present?

        base_attrs.compact
      end

      # Generate a unique component ID if not provided
      def generate_id(prefix = 'component')
        @generate_id ||= "#{prefix}-#{SecureRandom.hex(4)}"
      end

      # Cache generated IDs to prevent memory leaks
      def cached_id(prefix = 'component')
        @cached_id ||= generate_id(prefix)
      end

      # Handle rendering errors gracefully
      def handle_render_error(error)
        if defined?(Rails) && Rails.env.development?
          # In development, show error details
          div(class: 'preline-error-boundary',
              style: 'color: red; border: 1px solid red; padding: 1rem; margin: 1rem 0;') do
            h4 { "Component Error: #{self.class.name}" }
            pre { error.message }
            details do
              summary { 'Stack trace' }
              pre(style: 'font-size: 0.8em;') { error.backtrace.first(10).join("\n") }
            end
          end
        else
          # In production, log error and render nothing
          Rails.logger.error "Component render error in #{self.class.name}: #{error.message}"
          nil
        end
      end

      # Simple icon rendering helper
      def render_icon(icon_name, additional_classes: nil)
        return nil if icon_name.blank?

        # Simple sanitization - only allow alphanumeric and hyphens
        safe_icon = icon_name.to_s.gsub(/[^a-zA-Z0-9-]/, '')
        return nil if safe_icon.empty?

        classes = ['fas', "fa-#{safe_icon}"]
        classes << additional_classes if additional_classes.present?

        i(class: classes.compact.join(' '))
      end

      # Helper to map status values to badge variants
      def status_variant(status)
        status_variants = {
          'active' => :success,
          'qualified' => :success,
          'draft' => :warning,
          'inactive' => :gray,
          'sent' => :success,
          'scheduled' => :primary,
          'growth' => :success,
          'mature' => :success,
          'launch' => :primary
        }
        status_variants[status&.downcase] || :gray
      end
    end
  end
end
