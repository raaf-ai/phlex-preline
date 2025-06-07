# frozen_string_literal: true

module Components
  module Preline
    # ChatBubble component for displaying chat messages with avatars and metadata
    # Creates a chat bubble with sender information, timestamp, and customizable positioning
    #
    # @example Basic chat message
    #   ChatBubble(sender: "John Doe", time: "10:30 AM") do
    #     "Hello, how can I help you today?"
    #   end
    #
    # @example Chat message with avatar on the right
    #   ChatBubble(
    #     sender: "Support Agent",
    #     avatar: "/images/agent.jpg",
    #     time: "10:32 AM",
    #     position: :right
    #   ) do
    #     "I'd be happy to assist you with your question."
    #   end
    #
    # @example Chat message with initial avatar
    #   ChatBubble(
    #     sender: "Customer",
    #     avatar: true,  # Uses first letter of sender name
    #     time: "2 minutes ago"
    #   ) do
    #     "I need help with my order."
    #   end
    #
    # @example Multiple line chat message
    #   ChatBubble(sender: "Assistant") do
    #     div { "Here's what I found:" }
    #     ul(class: "list-disc list-inside mt-2") do
    #       li { "First item" }
    #       li { "Second item" }
    #     end
    #   end
    class ChatBubble < ::Components::Preline::PrelineComponent
      # @param sender [String, nil] Name of the message sender
      # @param avatar [String, Boolean, nil] Avatar image URL or true for initial avatar
      # @param time [String, nil] Timestamp or time ago string
      # @param position [Symbol] Position of the chat bubble (:left or :right)
      # @param attrs [Hash] Additional HTML attributes and options
      # @option attrs [String] :class Additional CSS classes
      # @option attrs [Hash] :* Any other HTML attributes
      def initialize(sender: nil, avatar: nil, time: nil, position: :left, **attrs)
        @sender = sender
        @avatar = avatar
        @time = time
        @position = position
        @custom_class = attrs.delete(:class)
        @html_attrs = attrs.except(:sender, :avatar, :time, :position)
        @options = attrs.slice(:sender, :avatar, :time, :position)
      end

      def view_template
        div(**html_attrs, class: wrapper_classes) do
          render_avatar if avatar && position == :left

          div(class: content_wrapper_classes) do
            div(class: sender_classes) { sender } if sender

            div(class: bubble_classes) do
              yield if block_given?
            end

            div(class: time_classes) { time } if time
          end

          render_avatar if avatar && position == :right
        end
      end

      private

      attr_reader :sender, :avatar, :time, :position, :custom_class, :html_attrs, :options

      def wrapper_classes
        base = 'hs-chat-bubble flex gap-x-3'
        position_class = position == :right ? 'justify-end' : ''

        [base, position_class, custom_class].compact.join(' ')
      end

      def content_wrapper_classes
        'flex flex-col gap-y-1 max-w-xs'
      end

      def bubble_classes
        base = 'hs-chat-bubble-content px-4 py-2 rounded-lg'

        position_class = if position == :right
                           'bg-blue-600 text-white'
                         else
                           'bg-gray-100 text-gray-800'
                         end

        [base, position_class].compact.join(' ')
      end

      def sender_classes
        base = 'text-xs font-medium'
        color = position == :right ? 'text-gray-600 text-end' : 'text-gray-600'

        [base, color].compact.join(' ')
      end

      def time_classes
        base = 'text-xs text-gray-500'
        align = position == :right ? 'text-end' : ''

        [base, align].compact.join(' ')
      end

      def render_avatar
        if avatar.is_a?(String)
          img(
            src: avatar,
            alt: sender || 'Avatar',
            class: 'hs-chat-avatar size-8 rounded-full'
          )
        else
          div(class: 'hs-chat-avatar size-8 rounded-full bg-gray-300 flex items-center justify-center') do
            span(class: 'text-xs font-medium text-white') do
              (sender || 'U').first.upcase
            end
          end
        end
      end
    end
  end
end
