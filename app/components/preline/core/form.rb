# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI form component that wraps Rails form helpers.
    # Provides consistent styling and structure for forms.
    #
    # @example Form with model
    #   render Components::Preline::Form.new(model: @user) do |form|
    #     render Components::Preline::Input.new(
    #       form: form,
    #       field: :email,
    #       label: "Email"
    #     )
    #     render Components::Preline::Button.new(
    #       text: "Submit",
    #       type: :submit
    #     )
    #   end
    #
    # @example Form with custom URL and method
    #   render Components::Preline::Form.new(
    #     url: search_path,
    #     method: :get,
    #     class: "space-y-4"
    #   ) do |form|
    #     # Form fields
    #   end
    class Form < ::Components::Preline::PrelineComponent
      # Initialize a new Form component
      #
      # @param model [ActiveRecord::Base, nil] ActiveRecord model for form binding
      # @param url [String, nil] Form action URL (uses model's route if not specified)
      # @param method [Symbol] HTTP method (:post, :patch, :put, :delete, :get)
      # @param local [Boolean] Disable remote form submission (Turbo)
      # @param class [String] Additional CSS classes for the form
      # @param data [Hash] Data attributes
      # @param attrs [Hash] Additional form options passed to form_with
      def initialize(
        model: nil,
        url: nil,
        method: :post,
        local: true,
        data: {},
        **attrs
      )
        # Validate parameters
        @model = model # Can be nil
        @url = validate_url!(url, 'url') if url
        @method = validate_inclusion!(method, 'method', %i[get post put patch delete])
        @local = validate_boolean!(local, 'local')
        @data = validate_hash!(data, 'data')

        # Store original class before extraction
        @form_class = attrs.delete(:class)

        # Merge data attributes into attrs for secure filtering
        attrs[:data] = (attrs[:data] || {}).merge(@data)

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template
        code_path 'Renders form component'
        form_options = build_form_options

        if @model
          code_path 'Renders form with model binding'
        else
          code_path 'Renders form with custom URL'
        end

        # Build form action
        action = if @model
                   if @model.respond_to?(:persisted?) && @model.persisted?
                     "/#{@model.model_name.route_key}/#{@model.to_param}"
                   else
                     "/#{@model.model_name.route_key}"
                   end
                 else
                   @url || '#'
                 end

        # Build form attributes
        form_attrs = form_options.merge(
          action: action, 
          method: @method == :get ? 'get' : 'post'
        )

        # Add data-remote if not local
        form_attrs[:'data-remote'] = 'true' unless @local

        form(**form_attrs) do
          # Add CSRF token for non-GET requests (Rails-compatible)
          if @method != :get && respond_to?(:csrf_token_tag)
            raw csrf_token_tag
          elsif @method != :get
            # Fallback: manual CSRF token (works in test environment)
            input(type: 'hidden', name: 'authenticity_token', value: csrf_token_value)
          end
          
          # Add UTF-8 enforcer
          input(type: 'hidden', name: 'utf8', value: '✓')

          # Add method override for non-GET/POST methods
          if @method && %i[get post].exclude?(@method)
            input(type: 'hidden', name: '_method', value: @method.to_s)
          end

          # Yield self as form builder for compatibility
          yield(self) if block_given?
        end
      end

      private

      # Get CSRF token value
      def csrf_token_value
        if defined?(Rails) && Rails.application.respond_to?(:config) && Rails.application.config.respond_to?(:force_ssl)
          # In Rails environment, try to get the real CSRF token
          if respond_to?(:form_authenticity_token)
            form_authenticity_token
          elsif defined?(ActionController::Base)
            ActionController::Base.new.send(:form_authenticity_token)
          else
            'csrf-token-placeholder'
          end
        else
          # In test environment, use a test token
          'test-token'
        end
      end

      # Form builder methods for compatibility
      def text_field(field, options = {})
        # Render the input directly instead of returning a string
        input(
          type: 'text',
          name: field.to_s,
          id: field.to_s,
          class: options[:class]
        )
      end

      def label(field, text = nil, options = {})
        # Render the label directly instead of returning a string
        text ||= field.to_s.humanize
        super(
          for: field.to_s,
          class: options[:class]
        ) { text }
      end

      private

      def build_form_options
        # Get component attributes with form classes
        opts = component_attributes(additional_classes: build_classes)

        code_path 'Renders form with custom HTTP method' if @method != :post
        code_path 'Renders form with remote submission' unless @local

        opts
      end

      def build_classes
        ['hs-form', @form_class].compact
      end
    end
  end
end
