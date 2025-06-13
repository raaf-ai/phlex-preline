# frozen_string_literal: true

module Components
  module Preline
    # FileUploadGallery component for multiple file uploads with preview
    #
    # @example Gallery upload for images
    #   render Components::Preline::FileUploadGallery.new(
    #     id: "gallery-upload",
    #     name: "images[]",
    #     accept: "image/*",
    #     max_files: 10,
    #     preview: true
    #   )
    #
    # @example Document gallery with custom styling
    #   render Components::Preline::FileUploadGallery.new(
    #     id: "document-gallery",
    #     name: "documents[]",
    #     accept: ".pdf,.doc,.docx",
    #     columns: 4
    #   )
    class FileUploadGallery < ::Components::Preline::PrelineComponent
      # @param id [String] Required ID for the dropzone element
      # @param name [String] Input name attribute (should end with [] for multiple)
      # @param accept [String] Accepted file types
      # @param max_files [Integer] Maximum number of files allowed
      # @param max_size [String] Maximum file size per file
      # @param preview [Boolean] Whether to show image previews
      # @param columns [Integer] Number of columns for preview grid (2-6)
      # @param message [String] Custom drop message
      # @param attrs [Hash] Additional HTML attributes
      def initialize(id:, name:, accept: nil, max_files: nil, max_size: nil,
                     preview: true, columns: 3, message: nil, **attrs)
        @id = id
        @name = name
        @accept = accept
        @max_files = max_files
        @max_size = max_size
        @preview = validate_boolean!(preview, 'preview')
        @columns = validate_inclusion!(columns, 'columns', [2, 3, 4, 5, 6])
        @message = message

        initialize_component(attrs)
      end

      def view_template
        div(**component_attributes(additional_classes: ['hs-file-upload-gallery']),
            data: { controller: 'file-upload-gallery' }.merge(dropzone_data_attributes)) do
          div(
            id: @id,
            class: 'dropzone',
            data: { 'file-upload-gallery-target': 'dropzone' }
          ) do
            # Drop zone area
            div(class: 'dz-message') do
              div(class: 'hs-file-upload-gallery-content') do
                # Upload icon
                svg(
                  class: 'hs-file-upload-gallery-icon',
                  stroke: 'currentColor',
                  fill: 'none',
                  viewBox: '0 0 48 48',
                  aria_hidden: 'true'
                ) do |s|
                  s.path(
                    d: 'M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02',
                    stroke_width: '2',
                    stroke_linecap: 'round',
                    stroke_linejoin: 'round'
                  )
                end

                p(class: 'hs-file-upload-gallery-text') { @message || I18n.t('preline.file_upload_gallery.message') }
                p(class: 'hs-file-upload-gallery-subtext') { I18n.t('preline.file_upload_gallery.or') }

                button(
                  type: 'button',
                  class: 'hs-file-upload-gallery-button'
                ) { I18n.t('preline.file_upload_gallery.browse_files') }

                # File constraints
                div(class: 'hs-file-upload-gallery-constraints') do
                  p { "#{I18n.t('preline.file_upload_gallery.accepted_types')}: #{format_accept_types}" } if @accept
                  p { "#{I18n.t('preline.file_upload.max_size')}: #{@max_size}" } if @max_size
                  p { "#{I18n.t('preline.file_upload_gallery.max_files')}: #{@max_files}" } if @max_files
                end
              end

              yield if block_given?
            end

            # Preview container
            if @preview
              div(
                class: "dz-preview-container hs-file-upload-gallery-cols-#{@columns} mt-4",
                style: 'display: none;',
                data: { 'file-upload-gallery-target': 'previewContainer' }
              )
            end
          end
        end
      end

      private

      def dropzone_data_attributes
        data = {
          'file-upload-gallery-name-value': @name,
          'file-upload-gallery-gallery-value': @preview.to_s
        }

        data['file-upload-gallery-accept-value'] = @accept if @accept
        data['file-upload-gallery-max-files-value'] = @max_files.to_s if @max_files
        data['file-upload-gallery-max-size-value'] = @max_size if @max_size

        data
      end

      def format_accept_types
        return '' unless @accept

        # Convert mime types and extensions to readable format
        types = @accept.split(',').map(&:strip).map do |type|
          case type
          when 'image/*' then I18n.t('preline.file_upload_gallery.images')
          when 'video/*' then I18n.t('preline.file_upload_gallery.videos')
          when 'audio/*' then I18n.t('preline.file_upload_gallery.audio')
          when '.pdf' then 'PDF'
          when '.doc', '.docx' then 'Word'
          when '.xls', '.xlsx' then 'Excel'
          when '.ppt', '.pptx' then 'PowerPoint'
          else type.upcase.delete('.')
          end
        end

        types.join(', ')
      end
    end
  end
end
