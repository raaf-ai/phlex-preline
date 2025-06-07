# frozen_string_literal: true

module Components
  module Preline
    # A Preline UI card component for organizing content in a container with optional header and footer.
    # Supports title, subtitle, description, and customizable header/footer actions.
    #
    # @example Basic card with content
    #   render Components::Preline::Card.new(title: "Card Title") do
    #     p { "Card content goes here" }
    #   end
    #
    # @example Card with all features
    #   render Components::Preline::Card.new(
    #     title: "User Profile",
    #     subtitle: "Manage your account",
    #     description: "Update your personal information",
    #     header_actions: [
    #       { text: "Edit", variant: :primary, size: :sm }
    #     ],
    #     footer_actions: [
    #       { text: "Save", variant: :success },
    #       { text: "Cancel", variant: :secondary }
    #     ]
    #   )
    #
    # @example Card with custom styling
    #   render Components::Preline::Card.new(
    #     title: "Statistics",
    #     class: "shadow-lg",
    #     header_class: "bg-gray-50",
    #     body_class: "p-6"
    #   ) do
    #     render Components::Preline::Grid.new(cols: 3) do
    #       # Grid content
    #     end
    #   end
    class Card < ::Components::Preline::PrelineComponent
      # Initialize a new Card component
      #
      # @param title [String, nil] Card header title
      # @param subtitle [String, nil] Card header subtitle
      # @param description [String, nil] Card body description text
      # @param header_actions [Array<Hash>] Array of button props for header actions
      # @param footer_actions [Array<Hash>] Array of button props for footer actions
      # @param class [String] Additional CSS classes for the card wrapper
      # @param body_class [String] Additional CSS classes for the card body
      # @param header_class [String] Additional CSS classes for the card header
      # @param footer_class [String] Additional CSS classes for the card footer
      # @param attrs [Hash] Additional HTML attributes
      def initialize(
        title: nil,
        subtitle: nil,
        description: nil,
        header_actions: [],
        footer_actions: [],
        body_class: '',
        header_class: '',
        footer_class: '',
        **attrs
      )
        # Validate inputs
        @title = title
        @subtitle = subtitle
        @description = description
        @header_actions = validate_array!(header_actions, 'header_actions')
        @footer_actions = validate_array!(footer_actions, 'footer_actions')
        @body_class = validate_css_class!(body_class)
        @header_class = validate_css_class!(header_class)
        @footer_class = validate_css_class!(footer_class)

        # Use secure attribute extraction
        initialize_component(attrs)
      end

      def view_template(&block)
        card_attrs = component_attributes(additional_classes: build_classes)

        div(**card_attrs) do
          render_header if has_header?
          render_body(&block)
          render_footer if has_footer?
        end
      end

      private

      def has_header?
        @title.present? || @subtitle.present? || @header_actions.any?
      end

      def has_footer?
        @footer_actions.any?
      end

      def render_header
        code_path 'Renders card header section'
        div(class: "hs-card-header theme-card-header #{@header_class}".strip) do
          if @title || @subtitle
            code_path 'Renders card title and subtitle'
            div do
              h3(class: 'hs-card-title') { plain @title } if @title
              p(class: 'hs-card-subtitle') { plain @subtitle } if @subtitle
            end
          end

          if @header_actions.any?
            code_path 'Renders card header actions'
            div(class: 'hs-card-header-actions') do
              @header_actions.each { |action| render_action(action) }
            end
          end
        end
      end

      def render_body
        div(class: "hs-card-body theme-card-body #{@body_class}".strip) do
          if @description
            code_path 'Renders card description'
            p(class: 'hs-card-description') { plain @description }
          end
          yield if block_given?
        end
      end

      def render_footer
        code_path 'Renders card footer with actions'
        div(class: "hs-card-footer #{@footer_class}".strip) do
          div(class: 'hs-flex hs-gap-2') do
            @footer_actions.each { |action| render_action(action) }
          end
        end
      end

      def render_action(action)
        if action[:type] == :button
          Button(**action.except(:type))
        elsif action[:url]
          Button(**action, tag: :a, href: action[:url])
        else
          span { action[:text] }
        end
      end

      def build_classes
        %w[hs-card theme-card]
      end
    end
  end
end
