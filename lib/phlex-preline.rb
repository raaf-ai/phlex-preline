# frozen_string_literal: true

require 'phlex'
require_relative 'preline/version'
require_relative 'preline/errors'
require_relative 'preline/validatable'
require_relative 'components/preline'
require_relative 'phlex/preline/base_field_component'
require_relative 'phlex/preline/text_field'
require_relative 'phlex/preline/select_field'
require_relative 'phlex/preline/textarea_field'
require_relative 'phlex/preline/naics_select'
require_relative 'phlex/preline/naics_selector'
require_relative 'phlex/preline/sbi_select'
require_relative 'phlex/preline/nace_select'
require_relative 'phlex/preline/currency_field'
require_relative 'phlex/preline/m49_select'
require_relative 'phlex/preline/region_selector'
require_relative 'preline/engine' if defined?(Rails)

module Phlex
  module Preline
    # Allow including Phlex::Preline to get access to Components::Preline
    def self.included(base)
      base.include(::Components::Preline)
    end
  end
end
