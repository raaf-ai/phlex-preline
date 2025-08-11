# frozen_string_literal: true

module Components
  extend ::Phlex::Kit

  module Preline
    # Base component class for all Preline UI components.
    # Provides common functionality including security, validation, error handling,
    # and Rails integration helpers. All Preline components inherit from this class
    # to ensure consistent behavior and security practices.
    #
    # @abstract Subclass and implement {#view_template} to create a component
    # @since 0.1.0
    # @api public
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

      # Wraps the template rendering with component identification comments in development
      # and error handling. Provides error boundaries to prevent component failures from
      # breaking the entire page.
      #
      # @yield The component's template rendering
      # @return [void]
      # @api public
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

      # Adds a code path comment for debugging and test coverage tracking.
      # Only outputs in test environment to help verify which code paths are executed.
      #
      # @param path [String] Description of the code path being executed
      # @return [void]
      # @api private
      def code_path(path)
        return unless defined?(Rails) && Rails.env.test?

        comment { "Codepath: #{path} executed" }
      end

      private

      # Common initialization pattern for components. Extracts and sanitizes standard
      # HTML attributes including class, data attributes, ARIA attributes, and ID.
      #
      # @param attrs [Hash] HTML attributes to process
      # @return [void]
      # @api private
      def initialize_component(attrs = {})
        @custom_class = attrs.delete(:class)
        @data_attrs = attrs.delete(:data) || {}
        @aria_attrs = attrs.delete(:aria) || {}
        @id = attrs.delete(:id)

        # Store sanitized attributes
        @extracted_attrs = extract_attributes(attrs)
      end

      # Builds merged attributes for rendering using Phlex 2.0 mix pattern.
      # Combines extracted attributes with additional classes and attributes,
      # ensuring all values are properly sanitized.
      #
      # @param additional_classes [String, Array<String>, nil] CSS classes to add
      # @param additional_attrs [Hash] Additional HTML attributes to merge
      # @return [Hash] Sanitized and merged HTML attributes
      # @api private
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

      # Generates a unique component ID if not provided.
      # Uses SecureRandom to ensure uniqueness across component instances.
      #
      # @param prefix [String] Prefix for the generated ID
      # @return [String] Unique component ID
      # @api private
      def generate_id(prefix = 'component')
        @generate_id ||= "#{prefix}-#{SecureRandom.hex(4)}"
      end

      # Caches generated IDs to prevent memory leaks and ensure consistency.
      # Returns the same ID for multiple calls within the same component instance.
      #
      # @param prefix [String] Prefix for the generated ID
      # @return [String] Cached unique component ID
      # @api private
      def cached_id(prefix = 'component')
        @cached_id ||= generate_id(prefix)
      end

      # Handles rendering errors gracefully. In development, displays detailed error
      # information. In production, logs the error and renders nothing to prevent
      # breaking the entire page.
      #
      # @param error [StandardError] The error that occurred during rendering
      # @return [void, nil]
      # @api private
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

      # Renders a Font Awesome icon with proper sanitization.
      # Strips potentially dangerous characters from icon names to prevent XSS.
      #
      # @param icon_name [String, Symbol] Name of the Font Awesome icon
      # @param additional_classes [String, nil] Additional CSS classes for the icon
      # @return [void, nil] Renders icon or returns nil if icon_name is invalid
      # @api private
      def render_icon(icon_name, additional_classes: nil)
        return nil if icon_name.blank?

        # Simple sanitization - only allow alphanumeric and hyphens
        safe_icon = icon_name.to_s.gsub(/[^a-zA-Z0-9-]/, '')
        return nil if safe_icon.empty?

        classes = ['fas', "fa-#{safe_icon}"]
        classes << additional_classes if additional_classes.present?

        i(class: classes.compact.join(' '))
      end

      # Maps status values to appropriate badge color variants.
      # Provides consistent color coding across the application.
      #
      # @param status [String, Symbol] Status value to map
      # @return [Symbol] Badge variant symbol (:success, :warning, :primary, :gray)
      # @api private
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
