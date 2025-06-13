# frozen_string_literal: true

module Components
  module Preline
    # FileUpload component for drag-and-drop file uploads
    #
    # @example Basic file upload with drag-and-drop
    #   render Components::Preline::FileUpload.new(
    #     id: "file-upload",
    #     name: "files",
    #     max_size: "2MB"
    #   )
    #
    # @example With custom message
    #   render Components::Preline::FileUpload.new(
    #     id: "document-upload",
    #     name: "documents[]",
    #     multiple: true
    #   ) do
    #     p(class: "text-xs text-gray-400 mt-2") { "PDF, DOC, DOCX up to 10MB" }
    #   end
    class FileUpload < ::Components::Preline::PrelineComponent
      # @param id [String] Required ID for the dropzone element
      # @param name [String] Input name attribute
      # @param max_size [String] Maximum file size (e.g., "2MB", "5MB")
      # @param accept [String] Accepted file types
      # @param multiple [Boolean] Whether to allow multiple files
      # @param message [String] Custom drop message
      # @param attrs [Hash] Additional HTML attributes
      def initialize(id:, name:, max_size: nil, accept: nil, multiple: false, message: nil, **attrs)
        @id = id
        @name = name
        @max_size = max_size
        @accept = accept
        @multiple = validate_boolean!(multiple, 'multiple')
        @message = message

        initialize_component(attrs)
      end

      def view_template
        div(**component_attributes(additional_classes: ['hs-file-upload-wrapper']),
            data: { controller: 'file-upload' }.merge(dropzone_data_attributes)) do
          div(class: 'hs-file-upload-container') do
            div(
              id: @id,
              class: 'hs-file-upload-dropzone',
              data: { 'file-upload-target': 'dropzone' }
            ) do
              div(class: 'hs-file-upload-message') do
                plain @message || default_message
                p(class: 'hs-file-upload-constraint') { "#{I18n.t('preline.file_upload.max_size')} #{@max_size}." } if @max_size
                yield if block_given?
              end
            end
          end
        end
      end

      private

      def default_message
        I18n.t('preline.file_upload.drop_or_browse')
      end

      def dropzone_data_attributes
        data = {
          'file-upload-name-value': @name
        }

        data['file-upload-accept-value'] = @accept if @accept
        data['file-upload-multiple-value'] = @multiple.to_s if @multiple
        data['file-upload-max-size-value'] = @max_size if @max_size

        data
      end
    end
  end
end
