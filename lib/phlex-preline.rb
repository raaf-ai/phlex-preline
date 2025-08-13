# frozen_string_literal: true

require 'phlex'
require_relative 'preline/version'
require_relative 'preline/errors'
require_relative 'preline/validatable'
require_relative 'components/preline'
require_relative 'preline/engine' if defined?(Rails)

module Phlex
  module Preline
    # Allow including Phlex::Preline to get access to Components::Preline
    def self.included(base)
      base.include(::Components::Preline)
    end
  end
end
