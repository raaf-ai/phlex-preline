#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'

# List of components that need tests
COMPONENTS_WITHOUT_TESTS = %w[
  accordion advanced_select avatar avatar_group blockquote breadcrumb
  button_group carousel chat_bubble checkbox collapse color_picker
  columns combo_box container context_menu copy_markup custom_scrollbar
  datepicker devices divider dropdown file_input file_upload_progress
  flex form grid input_group input_number kbd layout_splitter
  legend_indicator list list_group mega_menu navbar navs offcanvas
  pin_input popover radio range_slider ratings scrollspy search_box
  select sidebar skeleton spinner stepper strong_password styled_icons
  switch table tabs text_area time_picker timeline toast toggle_count
  toggle_password tooltip tree_view typography
].freeze

def generate_test_file(component_name)
  class_name = component_name.split('_').map(&:capitalize).join
  file_path = "spec/components/preline/#{component_name}_spec.rb"

  # Check if component file exists
  component_file = "app/components/preline/core/#{component_name}.rb"
  return unless File.exist?(component_file)

  # Read component to understand its structure
  component_content = File.read(component_file)

  # Extract initialize parameters using regex
  init_match = component_content.match(/def initialize\((.*?)\)/m)
  init_match ? init_match[1].gsub(/\s+/, ' ').strip : ''

  # Generate basic test structure
  test_content = <<~RUBY
    # frozen_string_literal: true

    require 'spec_helper'

    RSpec.describe Preline::#{class_name}, type: :component do
      describe '#view_template' do
        it 'renders basic #{component_name.gsub('_', ' ')}' do
          component = described_class.new
          output = render_phlex(component)
    #{'      '}
          expect(output).to include('hs-#{component_name.gsub('_', '-')}')
        end
    #{'    '}
        # TODO: Add more specific tests based on component functionality
        # - Test different configurations
        # - Test code paths with have_executed_code_path
        # - Test edge cases
        # - Test validation
      end
    #{'  '}
      describe 'initialization' do
        it 'accepts valid parameters' do
          expect { described_class.new }.not_to raise_error
        end
      end
    end
  RUBY

  # Create directory if it doesn't exist
  FileUtils.mkdir_p(File.dirname(file_path))

  # Write test file
  File.write(file_path, test_content)
  puts "Generated: #{file_path}"

  # Also add to spec_helper.rb aliases
  add_to_spec_helper(class_name)
end

def add_to_spec_helper(class_name)
  spec_helper_path = 'spec/spec_helper.rb'
  content = File.read(spec_helper_path)

  # Find the Preline module section
  return unless content.match(/module Preline\n(.*?)\nend/m)

  aliases = Regexp.last_match(1)
  return if aliases.include?("#{class_name} = Components::Preline::#{class_name}")

  # Add new alias before PrelineComponent
  new_alias = "  #{class_name} = Components::Preline::#{class_name}\n"
  content.sub!('  PrelineComponent = Components::Preline::PrelineComponent', "#{new_alias}  PrelineComponent = Components::Preline::PrelineComponent")
  File.write(spec_helper_path, content)
  puts "Added alias for #{class_name} to spec_helper.rb"
end

# Generate tests for all missing components
COMPONENTS_WITHOUT_TESTS.each do |component|
  generate_test_file(component)
end

puts "\nDone! Generated #{COMPONENTS_WITHOUT_TESTS.size} test files."
puts "Note: These are basic test templates. You'll need to:"
puts '1. Add code_path calls to the component files'
puts '2. Update the tests with specific functionality tests'
puts '3. Add validation tests'
puts '4. Test all configuration options'
