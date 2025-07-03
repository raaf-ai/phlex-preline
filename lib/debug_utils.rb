# frozen_string_literal: true

module PhlexPreline
  module DebugUtils
    VALID_LEVELS = %w[debug info warn error fatal].freeze

    class << self
      def enabled?
        ENV.fetch('DEBUG', 'false').downcase == 'true'
      end

      def level
        ENV.fetch('DEBUG_LEVEL', 'info').downcase
      end

      def output_target
        ENV.fetch('DEBUG_OUTPUT', 'console').downcase
      end

      def component_debug_enabled?
        ENV.fetch('COMPONENT_DEBUG', 'false').downcase == 'true'
      end

      def javascript_debug_enabled?
        ENV.fetch('JS_DEBUG', 'false').downcase == 'true'
      end

      def log(level, message, context: {})
        return unless enabled? && should_log?(level)

        formatted_message = format_message(message, context)
        
        case output_target
        when 'file'
          log_to_file(level, formatted_message)
        when 'both'
          log_to_console(level, formatted_message)
          log_to_file(level, formatted_message)
        else
          log_to_console(level, formatted_message)
        end
      end

      def component_log(component_name, message, context: {})
        return unless component_debug_enabled?
        log(:debug, "[COMPONENT:#{component_name}] #{message}", context: context)
      end

      def js_log(message, context: {})
        return unless javascript_debug_enabled?
        log(:debug, "[JS] #{message}", context: context)
      end

      def breakpoint_if_enabled(condition = true)
        return unless enabled? && condition
        require 'debug'
        debugger
      end

      def benchmark(label)
        return yield unless enabled?
        
        start_time = Time.current
        result = yield
        duration = Time.current - start_time
        
        log(:info, "BENCHMARK [#{label}]: #{duration.round(3)}s")
        result
      end

      def render_debug(component_class, **props)
        return unless component_debug_enabled?
        
        log(:debug, "RENDER [#{component_class}]")
        props.each do |key, value|
          log(:debug, "  #{key}: #{value.inspect}")
        end
      end

      private

      def should_log?(message_level)
        level_priority(message_level) >= level_priority(level)
      end

      def level_priority(level_name)
        VALID_LEVELS.index(level_name.to_s) || 0
      end

      def format_message(message, context)
        timestamp = Time.current.strftime('%Y-%m-%d %H:%M:%S')
        context_str = context.any? ? " | Context: #{context.inspect}" : ""
        "[#{timestamp}] DEBUG: #{message}#{context_str}"
      end

      def log_to_console(level, message)
        puts message
      end

      def log_to_file(level, message)
        log_file = File.join(Dir.pwd, 'log', 'debug.log')
        FileUtils.mkdir_p(File.dirname(log_file))
        File.open(log_file, 'a') { |f| f.puts message }
      end
    end
  end
end