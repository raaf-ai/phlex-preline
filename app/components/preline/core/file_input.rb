# frozen_string_literal: true

module Components
  module Preline
    # FileInput component for file upload fields with drag-and-drop support
    #
    # @example Basic file input
    #   render Components::Preline::FileInput.new(
    #     name: "avatar",
    #     label: "Profile Picture",
    #     accept: "image/*"
    #   )
    #
    # @example Multiple file upload
    #   render Components::Preline::FileInput.new(
    #     name: "documents[]",
    #     label: "Upload Documents",
    #     accept: ".pdf,.doc,.docx",
    #     multiple: true
    #   )
    #
    # @example With custom content
    #   render Components::Preline::FileInput.new(
    #     name: "resume",
    #     label: "Resume",
    #     accept: ".pdf"
    #   ) do
    #     p(class: "text-xs text-gray-500 mt-1") { "PDF files only, max 5MB" }
    #   end
    class FileInput < ::Components::Preline::PrelineComponent
      # @param name [String] Input name attribute
      # @param id [String] Optional input ID (auto-generated if not provided)
      # @param label [String] Optional label text
      # @param accept [String] Accepted file types (e.g. "image/*", ".pdf")
      # @param multiple [Boolean] Whether to allow multiple files (default: false)
      # @param disabled [Boolean] Whether input is disabled (default: false)
      # @param attrs [Hash] Additional HTML attributes
      def initialize(name:, id: nil, label: nil, accept: nil, multiple: false, disabled: false, **attrs)
        @name = name
        @id = id || "file_#{name}_#{SecureRandom.hex(4)}"
        @label = label
        @accept = accept
        @multiple = multiple
        @disabled = disabled

        # Extract standard HTML attributes
        @html_attrs = attrs.slice(:data, :aria, :role)
        @custom_class = attrs.delete(:class)
        @options = attrs.except(:id, :data, :aria, :role)
      end

      def view_template
        div(**@options, class: wrapper_classes) do
          label(for: @id, class: label_classes) { @label } if @label

          label(for: @id, class: file_input_wrapper_classes) do
            input(
              **@html_attrs,
              type: 'file',
              id: @id,
              name: @name,
              accept: @accept,
              multiple: @multiple,
              disabled: @disabled,
              class: file_input_classes
            )
            span(class: button_classes) { I18n.t('preline.file_input.browse') }
            span(class: text_classes) { I18n.t('preline.file_input.or_drag_drop') }
            yield if block_given?
          end
        end
      end

      private

      def wrapper_classes
        'hs-file-input-wrapper'
      end

      def label_classes
        'block text-sm font-medium mb-2'
      end

      def file_input_wrapper_classes
        'hs-file-input-label flex items-center gap-x-3'
      end

      def file_input_classes
        'hs-file-input sr-only'
      end

      def button_classes
        'hs-file-input-button py-2 px-3 inline-flex items-center gap-x-2 text-sm font-medium rounded-lg border border-gray-200 bg-white text-gray-800 shadow-sm hover:bg-gray-50 disabled:opacity-50 disabled:pointer-events-none'
      end

      def text_classes
        'hs-file-input-text text-sm text-gray-600'
      end
    end
  end
end
