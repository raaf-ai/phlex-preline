# frozen_string_literal: true

# This file sets up the Components::Preline module structure
# and ensures all components are properly autoloaded

module Components
  # Provides UI components for Phlex-based Rails applications
  module Preline
    extend ::Phlex::Kit

    # Extension module for extension components
    module Extension
      extend ::Phlex::Kit
    end
  end
end
