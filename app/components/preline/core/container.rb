# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI container component for page layout and content wrapping.
    # Provides consistent spacing and responsive width constraints.
    #
    # @example Page container
    #   render Components::Preline::Container.new(type: :page) do
    #     # Page content with sidebar support
    #   end
    #
    # @example Fluid container
    #   render Components::Preline::Container.new(type: :fluid) do
    #     # Full-width content with padding
    #   end
    #
    # @example Default container with custom classes
    #   render Components::Preline::Container.new(
    #     class: "py-8",
    #     content_class: "space-y-6"
    #   ) do
    #     # Centered content with max-width
    #   end
    class Container < ::Components::Preline::PrelineComponent
      TYPES = {
        page: 'hs-page-container',
        fluid: 'hs-container-fluid',
        default: 'hs-container'
      }.freeze

      # Initialize a new Container component
      #
      # @param type [Symbol] Container type (:default, :fluid, :page)
      # @param class [String] Additional CSS classes for the container
      # @param content_class [String] Additional CSS classes for the content wrapper (page type only)
      # @param attrs [Hash] Additional HTML attributes
      def initialize(
        type: :default,
        content_class: '',
        **attrs
      )
        @type = type
        @content_class = content_class

        # Extract standard HTML attributes
        @custom_class = attrs.delete(:class)
        @html_attrs = attrs.slice(:id, :data, :aria, :role)
        @options = attrs.except(:id, :data, :aria, :role, :class)
      end

      def view_template
        code_path 'Renders container component'
        if @type == :page
          code_path 'Renders page container'
          div(**@html_attrs, **@options, class: build_container_classes) do
            div(class: ['hs-page-content', @content_class].compact.join(' ')) do
              if block_given?
                code_path 'Renders page content'
                yield
              end
            end
          end
        else
          code_path 'Renders standard container'
          div(**@html_attrs, **@options, class: build_container_classes) do
            if block_given?
              code_path 'Renders container content'
              yield
            end
          end
        end
      end

      private

      def build_container_classes
        [TYPES[@type], @custom_class].compact.join(' ')
      end
    end
  end
end
