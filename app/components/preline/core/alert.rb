# frozen_string_literal: true

module Components
  module Preline
    # Alert component for displaying notification messages
    #
    # @example Basic usage
    #   render Components::Preline::Alert.new(
    #     type: :success,
    #     message: "Your changes have been saved successfully!"
    #   )
    #
    # @example With title
    #   render Components::Preline::Alert.new(
    #     type: :error,
    #     title: "Error occurred",
    #     message: "Unable to save your changes. Please try again."
    #   )
    #
    # @example With multiple messages
    #   render Components::Preline::Alert.new(
    #     type: :warning,
    #     title: "Please fix the following issues:",
    #     message: ["Name is required", "Email format is invalid"],
    #     dismissible: false
    #   )
    class Alert < ::Components::Preline::PrelineComponent
      ALERT_VARIANTS = {
        'success' => { class: 'hs-alert-success', icon: 'check-circle' },
        'error' => { class: 'hs-alert-error', icon: 'exclamation-triangle' },
        'warning' => { class: 'hs-alert-warning', icon: 'exclamation-triangle' },
        'info' => { class: 'hs-alert-info', icon: 'info-circle' }
      }.freeze

      # @param type [Symbol, String] Type of alert (:success, :error, :warning, :info)
      # @param title [String, nil] Optional title for the alert
      # @param message [String, Array<String>] Alert message or array of messages
      # @param dismissible [Boolean] Whether the alert can be dismissed (default: true)
      # @param attrs [Hash] Additional HTML attributes
      def initialize(type:, message:, dismissible: true, **attributes)
        # Extract component-specific attributes with defaults
        @title = attributes.delete(:title)

        # Validate and normalize inputs with fallbacks
        normalized_type = type&.to_s
        @type = normalized_type && ALERT_VARIANTS.key?(normalized_type) ? normalized_type : 'info'
        @message = normalize_message(message)

        # Handle dismissible parameter - nil is treated as false
        @dismissible = dismissible == true

        # Use secure attribute extraction
        initialize_component(attributes)
      end

      def view_template
        variant = ALERT_VARIANTS[@type]

        alert_attrs = component_attributes(
          additional_classes: build_classes(variant),
          additional_attrs: {
            role: 'alert',
            'data-hs-alert' => ''
          }
        )

        div(**alert_attrs) do
          div(class: 'hs-alert-content') do
            render_icon(variant[:icon], additional_classes: 'hs-alert-icon')
            div do
              if @title
                code_path 'Renders an alert with both title and message'
                h3(class: 'hs-alert-title') { plain @title }
              end
              div(class: 'hs-alert-description') do
                if @message.is_a?(Array)
                  code_path 'Renders an alert with array of messages as list'
                  ul(class: 'hs-list hs-list-disc') do
                    @message.each do |msg|
                      li(class: 'hs-list-item') { plain safe_message(msg) }
                    end
                  end
                else
                  code_path 'Renders a simple alert with text message'
                  plain safe_message(@message)
                end
              end
            end
          end

          if @dismissible
            code_path 'Renders a dismissible alert with a close button'
            button(
              type: 'button',
              class: 'hs-alert-close',
              data: { hs_alert_close: '' },
              aria: { label: 'Close alert' }
            ) do
              render_icon('times')
            end
          end
        end
      end

      private

      attr_reader :type, :title, :message, :dismissible

      def build_classes(variant)
        ['hs-alert', variant[:class]]
      end

      def normalize_message(message)
        return '' if message.nil?
        return message if message.is_a?(String) || message.is_a?(Array)

        message.to_s
      end

      def safe_message(msg)
        return '' if msg.nil?
        return msg.to_s if msg.respond_to?(:to_s)

        msg
      end
    end
  end
end
