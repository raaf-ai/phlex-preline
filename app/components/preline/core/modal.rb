# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI modal component for displaying overlay dialogs.
    # Supports various sizes, positioning options, scrollable content, and customizable actions.
    #
    # @example Basic modal with yielding interface
    #   render Components::Preline::Modal.new(id: "my-modal") do |modal|
    #     modal.header do
    #       modal.h3 { "Confirm Action" }
    #     end
    #     modal.body do
    #       modal.p { "Are you sure you want to proceed?" }
    #     end
    #     modal.footer do
    #       modal.button(variant: :secondary) { "Cancel" }
    #       modal.button(variant: :primary) { "Confirm" }
    #     end
    #   end
    #
    # @example Modal with nested components
    #   render Components::Preline::Modal.new(
    #     id: "my-modal",
    #     title: "Confirm Action"
    #   ) do
    #     p { "Are you sure you want to proceed?" }
    #   end
    #
    # @example Modal with footer actions
    #   render Components::Preline::Modal.new(
    #     id: "edit-modal",
    #     title: "Edit Profile",
    #     footer_actions: [
    #       { text: "Cancel", variant: :secondary, dismiss: true },
    #       { text: "Save Changes", variant: :primary }
    #     ]
    #   ) do
    #     # Form content
    #   end
    #
    # @example Large centered modal with scrollable content
    #   render Components::Preline::Modal.new(
    #     id: "terms-modal",
    #     title: "Terms and Conditions",
    #     size: :lg,
    #     centered: true,
    #     scrollable: true
    #   ) do
    #     # Long content
    #   end
    #
    # @example Fullscreen modal without backdrop click
    #   render Components::Preline::Modal.new(
    #     id: "fullscreen-modal",
    #     title: "Image Editor",
    #     size: :fullscreen,
    #     backdrop: "static",
    #     close_button: false
    #   )
    class Modal < ::Components::Preline::PrelineComponent
      SIZES = {
        sm: 'hs-modal-sm',
        md: '', # default
        lg: 'hs-modal-lg',
        xl: 'hs-modal-xl',
        fullscreen: 'hs-modal-fullscreen'
      }.freeze

      # Initialize a new Modal component
      #
      # @param id [String] Unique identifier for the modal (required)
      # @param title [String, nil] Modal header title
      # @param size [Symbol] Size variant (:sm, :md, :lg, :xl, :fullscreen)
      # @param centered [Boolean] Vertically center the modal
      # @param scrollable [Boolean] Make modal body scrollable
      # @param backdrop [Boolean, String] Enable backdrop (true), disable (false), or "static" to prevent closing on click
      # @param keyboard [Boolean] Close modal on ESC key press
      # @param footer_actions [Array<Hash>] Array of button props for footer actions
      # @param close_button [Boolean] Show close button in header
      # @param class [String] Additional CSS classes for modal wrapper
      # @param dialog_class [String] Additional CSS classes for modal dialog
      # @param header_class [String] Additional CSS classes for modal header
      # @param body_class [String] Additional CSS classes for modal body
      # @param footer_class [String] Additional CSS classes for modal footer
      # @param attrs [Hash] Additional HTML attributes
      def initialize(
        id:,
        title: nil,
        size: :md,
        centered: false,
        scrollable: false,
        backdrop: true,
        keyboard: true,
        footer_actions: [],
        close_button: true,
        dialog_class: '',
        header_class: '',
        body_class: '',
        footer_class: '',
        **attrs
      )
        # Validate required parameters
        @id = validate_html_id!(validate_required!(id, 'id'))
        @title = title
        @size = validate_inclusion!(size, 'size', SIZES.keys)
        @centered = validate_boolean!(centered, 'centered')
        @scrollable = validate_boolean!(scrollable, 'scrollable')
        @backdrop = backdrop # Can be boolean or "static"
        @keyboard = validate_boolean!(keyboard, 'keyboard')
        @footer_actions = validate_array!(footer_actions, 'footer_actions')
        @close_button = validate_boolean!(close_button, 'close_button')
        @dialog_class = validate_css_class!(dialog_class)
        @header_class = validate_css_class!(header_class)
        @body_class = validate_css_class!(body_class)
        @footer_class = validate_css_class!(footer_class)

        # Extract standard HTML attributes
        @custom_class = attrs.delete(:class)
        @html_attrs = attrs.slice(:data, :aria, :role)
        @options = attrs.except(:data, :aria, :role, :class)
      end

      def view_template(&block)
        div(
          **@html_attrs,
          **@options,
          id: @id,
          class: build_wrapper_classes,
          tabindex: '-1',
          role: @html_attrs[:role] || 'dialog',
          aria: {
            hidden: 'true',
            labelledby: "#{@id}-label",
            modal: 'true',
            describedby: "#{@id}-body",
            **(@html_attrs[:aria] || {})
          },
          data: build_data_attributes
        ) do
          if block_given? && block.parameters.any? { |type, _| %i[opt req].include?(type) }
            render_dialog_with_yield(&block)
          else
            render_dialog(&block)
          end
        end
      end

      # Creates a modal header section
      def header(**attrs, &_block)
        classes = ['hs-modal-header', @header_class, attrs[:class]]
                  .compact
                  .join(' ')
                  .strip
        div(class: classes) do
          yield if block_given?
        end
      end

      # Creates a modal body section
      def body(**attrs, &_block)
        classes = ['hs-modal-body', @body_class, attrs.delete(:class)]
                  .compact
                  .join(' ')
                  .strip
        div(id: "#{@id}-body", class: classes, **attrs) do
          yield if block_given?
        end
      end

      # Creates a modal footer section
      def footer(**attrs, &_block)
        classes = ['hs-modal-footer', @footer_class, attrs[:class]]
                  .compact
                  .join(' ')
                  .strip
        div(class: classes) do
          yield if block_given?
        end
      end

      private

      def build_data_attributes
        attrs = @html_attrs[:data] || {}
        attrs['hs-modal-backdrop'] = @backdrop ? 'static' : 'false' unless @backdrop == true
        attrs['hs-modal-keyboard'] = 'false' unless @keyboard
        attrs
      end

      def build_wrapper_classes
        ['hs-modal', @custom_class].compact.join(' ')
      end

      def render_dialog(&block)
        div(
          class: build_dialog_classes,
          role: 'document'
        ) do
          div(class: 'hs-modal-content') do
            if @title || @close_button
              code_path 'Renders modal with header'
              render_header
            end
            render_body(&block)
            if @footer_actions.any?
              code_path 'Renders modal with footer actions'
              render_footer
            end
          end
        end
      end

      def render_dialog_with_yield
        div(
          class: build_dialog_classes,
          role: 'document'
        ) do
          div(class: 'hs-modal-content') do
            yield(self) if block_given?
          end
        end
      end

      def build_dialog_classes
        classes = ['hs-modal-dialog']
        classes << SIZES[@size] if SIZES[@size].present?
        if @centered
          code_path 'Renders centered modal'
          classes << 'hs-modal-dialog-centered'
        end
        if @scrollable
          code_path 'Renders scrollable modal'
          classes << 'hs-modal-dialog-scrollable'
        end
        classes << @dialog_class
        classes.join(' ').strip
      end

      def render_header
        div(class: "hs-modal-header #{@header_class}".strip) do
          if @title
            code_path 'Renders modal title'
            h5(id: "#{@id}-label", class: 'hs-modal-title') { @title }
          end

          if @close_button
            code_path 'Renders modal close button'
            button(
              type: 'button',
              class: 'hs-modal-close',
              data: { 'hs-overlay': "##{@id}" },
              aria: { label: I18n.t('preline.modal.close', default: 'Close') }
            ) do
              svg(
                class: 'hs-modal-close-icon',
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

      def render_body(&_block)
        div(id: "#{@id}-body", class: "hs-modal-body #{@body_class}".strip) do
          yield if block_given?
        end
      end

      def render_footer
        div(class: "hs-modal-footer #{@footer_class}".strip) do
          @footer_actions.each do |action|
            if action[:dismiss]
              code_path 'Renders dismissive footer action'
              render Button.new(
                **action.except(:dismiss),
                data: { 'hs-overlay': "##{@id}" }
              )
            else
              code_path 'Renders standard footer action'
              render Button.new(**action)
            end
          end
        end
      end
    end
  end
end
