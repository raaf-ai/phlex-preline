# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI toast component for notification messages.
    # Supports various styles, positions, and auto-dismiss functionality.
    #
    # @example Basic toast
    #   render Components::Preline::Toast.new(
    #     message: "Your changes have been saved!",
    #     variant: :success
    #   )
    #
    # @example Toast with title and actions
    #   render Components::Preline::Toast.new(
    #     title: "New Message",
    #     message: "You have received a new message from John Doe",
    #     variant: :info,
    #     actions: [
    #       { text: "View", href: "/messages/123", variant: :primary, size: :sm },
    #       { text: "Dismiss", variant: :secondary, size: :sm }
    #     ]
    #   )
    #
    # @example Warning toast with custom position
    #   render Components::Preline::Toast.new(
    #     message: "Your session will expire in 5 minutes",
    #     variant: :warning,
    #     icon: "clock",
    #     position: :"bottom-center",
    #     auto_dismiss: false
    #   )
    class Toast < ::Components::Preline::PrelineComponent
      VARIANTS = {
        default: '',
        success: 'hs-toast-success',
        danger: 'hs-toast-danger',
        warning: 'hs-toast-warning',
        info: 'hs-toast-info'
      }.freeze

      POSITIONS = {
        'top-left': 'hs-toast-top-left',
        'top-center': 'hs-toast-top-center',
        'top-right': 'hs-toast-top-right',
        'bottom-left': 'hs-toast-bottom-left',
        'bottom-center': 'hs-toast-bottom-center',
        'bottom-right': 'hs-toast-bottom-right'
      }.freeze

      # Initialize a new Toast component
      #
      # @param title [String, nil] Toast title (optional)
      # @param message [String] Toast message content
      # @param variant [Symbol] Style variant (:default, :success, :danger, :warning, :info)
      # @param icon [String, Symbol, nil] Custom icon or use variant default
      # @param dismissible [Boolean] Show dismiss button
      # @param auto_dismiss [Boolean] Automatically dismiss after duration
      # @param duration [Integer] Auto-dismiss duration in milliseconds
      # @param position [Symbol] Screen position (:"top-left", :"top-center", :"top-right", :"bottom-left", :"bottom-center", :"bottom-right")
      # @param actions [Array<Hash>] Action buttons/links to display
      # @param class [String] Additional CSS classes
      # @param id [String, nil] Custom ID for the toast
      def initialize(
        message:, title: nil,
        variant: :default,
        icon: nil,
        dismissible: true,
        auto_dismiss: true,
        duration: 5000,
        position: :'top-right',
        actions: [],
        id: nil,
        **attrs
      )
        # Validate inputs
        @title = title
        @message = validate_required!(message, 'message')
        @variant = validate_inclusion!(variant, 'variant', VARIANTS.keys)
        @icon = icon
        @dismissible = validate_boolean!(dismissible, 'dismissible')
        @auto_dismiss = validate_boolean!(auto_dismiss, 'auto_dismiss')
        @duration = validate_positive_integer!(duration, 'duration')
        @position = validate_inclusion!(position, 'position', POSITIONS.keys)
        @actions = validate_array!(actions, 'actions')
        @id = validate_html_id!(id) || cached_id('toast')

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template
        toast_attrs = component_attributes(
          additional_classes: build_classes,
          additional_attrs: {
            id: @id,
            role: 'alert',
            data: build_data_attributes
          }
        )

        div(**toast_attrs) do
          render_icon if @icon
          render_content
          render_actions if @actions.any?
          render_dismiss_button if @dismissible
        end
      end

      private

      def build_classes
        classes = ['hs-toast']
        classes << VARIANTS[@variant] if VARIANTS[@variant].present?
        classes << POSITIONS[@position] if @position
        classes
      end

      def build_data_attributes
        attrs = {}
        attrs['hs-remove-element'] = "##{@id}" if @auto_dismiss
        attrs['hs-remove-element-after'] = @duration.to_s if @auto_dismiss
        attrs
      end

      def render_icon
        div(class: 'hs-toast-icon') do
          if @icon
            # Use render_icon method for custom icons
            super(@icon)
          else
            render_variant_icon
          end
        end
      end

      def render_variant_icon
        case @variant
        when :success
          svg(class: 'hs-toast-icon-svg', viewBox: '0 0 20 20', fill: 'currentColor') do |s|
            s.path(
              fill_rule: 'evenodd',
              d: 'M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z',
              clip_rule: 'evenodd'
            )
          end
        when :danger
          svg(class: 'hs-toast-icon-svg', viewBox: '0 0 20 20', fill: 'currentColor') do |s|
            s.path(
              fill_rule: 'evenodd',
              d: 'M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z',
              clip_rule: 'evenodd'
            )
          end
        when :warning
          svg(class: 'hs-toast-icon-svg', viewBox: '0 0 20 20', fill: 'currentColor') do |s|
            s.path(
              fill_rule: 'evenodd',
              d: 'M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z',
              clip_rule: 'evenodd'
            )
          end
        when :info
          svg(class: 'hs-toast-icon-svg', viewBox: '0 0 20 20', fill: 'currentColor') do |s|
            s.path(
              fill_rule: 'evenodd',
              d: 'M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z',
              clip_rule: 'evenodd'
            )
          end
        end
      end

      def render_content
        div(class: 'hs-toast-body') do
          h5(class: 'hs-toast-title') { plain @title } if @title
          p(class: 'hs-toast-message') { plain @message }
        end
      end

      def render_actions
        div(class: 'hs-toast-actions') do
          @actions.each do |action|
            if action[:type] == :link
              Link(**action.except(:type))
            else
              Button(**action.except(:type))
            end
          end
        end
      end

      def render_dismiss_button
        button(
          type: 'button',
          class: 'hs-toast-close',
          data: { 'hs-remove-element': "##{@id}" },
          aria: { label: 'Close' }
        ) do
          svg(
            class: 'hs-toast-close-icon',
            width: '16',
            height: '16',
            viewBox: '0 0 16 16',
            fill: 'currentColor'
          ) do |s|
            s.path(
              d: 'M4.646 4.646a.5.5 0 0 1 .708 0L8 7.293l2.646-2.647a.5.5 0 0 1 .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 5.354a.5.5 0 0 1 0-.708z'
            )
          end
        end
      end
    end
  end
end
