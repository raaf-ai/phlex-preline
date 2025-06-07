# frozen_string_literal: true

module Phlex
  module Preline
    # Base error class for all Preline-specific errors
    class Error < StandardError; end

    # Raised when a component receives invalid configuration
    class ComponentError < Error; end

    # Raised when validation fails
    class ValidationError < ComponentError; end

    # Raised when a required parameter is missing
    class MissingParameterError < ValidationError; end

    # Raised when a parameter has an invalid value
    class InvalidParameterError < ValidationError; end

    # Raised when a component is used incorrectly
    class UsageError < ComponentError; end

    # Raised when a component's dependencies are not met
    class DependencyError < ComponentError; end

    # Raised when rendering fails
    class RenderError < ComponentError; end
  end
end
