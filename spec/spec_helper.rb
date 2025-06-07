# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/'
  add_group 'Components', 'app/components'
  add_group 'Library', 'lib'
  minimum_coverage 80
end

require 'bundler/setup'
require 'rails'
require 'phlex'
require 'active_support/all'
require 'active_support/core_ext/string/output_safety'
require 'uri'
require 'securerandom'
require 'logger'
require 'nokogiri'

# Set up minimal Rails environment for testing
Rails.env = 'test'
Rails.logger = Logger.new(nil) # Suppress logs during tests

# Ensure html_safe is available for test strings
class String
  def html_safe
    ActiveSupport::SafeBuffer.new(self)
  end unless method_defined?(:html_safe)
end

# Load the main preline module (which loads the concerns)
require 'phlex-preline'
require_relative '../app/components/preline/base_component'
require_relative '../app/components/preline/preline_component'

# Load all Preline components
Dir[File.join(__dir__, '../app/components/preline/core/*.rb')].each { |file| require file }

# Create aliases for testing - map Components::Preline to Preline::
module Preline
  Alert = Components::Preline::Alert
  Badge = Components::Preline::Badge
  Button = Components::Preline::Button
  Card = Components::Preline::Card
  Image = Components::Preline::Image
  Link = Components::Preline::Link
  Progress = Components::Preline::Progress
  Pagination = Components::Preline::Pagination
  Modal = Components::Preline::Modal
  Input = Components::Preline::Input
  Accordion = Components::Preline::Accordion
  AdvancedSelect = Components::Preline::AdvancedSelect
  Avatar = Components::Preline::Avatar
  AvatarGroup = Components::Preline::AvatarGroup
  Blockquote = Components::Preline::Blockquote
  Breadcrumb = Components::Preline::Breadcrumb
  ButtonGroup = Components::Preline::ButtonGroup
  Carousel = Components::Preline::Carousel
  ChatBubble = Components::Preline::ChatBubble
  Checkbox = Components::Preline::Checkbox
  Collapse = Components::Preline::Collapse
  ColorPicker = Components::Preline::ColorPicker
  Columns = Components::Preline::Columns
  ComboBox = Components::Preline::ComboBox
  Container = Components::Preline::Container
  ContextMenu = Components::Preline::ContextMenu
  CopyMarkup = Components::Preline::CopyMarkup
  CustomScrollbar = Components::Preline::CustomScrollbar
  Datepicker = Components::Preline::Datepicker
  Devices = Components::Preline::Devices
  Divider = Components::Preline::Divider
  Dropdown = Components::Preline::Dropdown
  FileInput = Components::Preline::FileInput
  FileUploadProgress = Components::Preline::FileUploadProgress
  Flex = Components::Preline::Flex
  Form = Components::Preline::Form
  Grid = Components::Preline::Grid
  InputGroup = Components::Preline::InputGroup
  InputNumber = Components::Preline::InputNumber
  Kbd = Components::Preline::Kbd
  LayoutSplitter = Components::Preline::LayoutSplitter
  LegendIndicator = Components::Preline::LegendIndicator
  List = Components::Preline::List
  ListGroup = Components::Preline::ListGroup
  MegaMenu = Components::Preline::MegaMenu
  Navbar = Components::Preline::Navbar
  Navs = Components::Preline::Navs
  Offcanvas = Components::Preline::Offcanvas
  PinInput = Components::Preline::PinInput
  Popover = Components::Preline::Popover
  Radio = Components::Preline::Radio
  RangeSlider = Components::Preline::RangeSlider
  Ratings = Components::Preline::Ratings
  Scrollspy = Components::Preline::Scrollspy
  SearchBox = Components::Preline::SearchBox
  Select = Components::Preline::Select
  Sidebar = Components::Preline::Sidebar
  Skeleton = Components::Preline::Skeleton
  Spinner = Components::Preline::Spinner
  Stepper = Components::Preline::Stepper
  StrongPassword = Components::Preline::StrongPassword
  StyledIcons = Components::Preline::StyledIcons
  Switch = Components::Preline::Switch
  Table = Components::Preline::Table
  TableHead = Components::Preline::TableHead
  TableBody = Components::Preline::TableBody
  TableRow = Components::Preline::TableRow
  TableHeaderCell = Components::Preline::TableHeaderCell
  TableCell = Components::Preline::TableCell
  Tabs = Components::Preline::Tabs
  TextArea = Components::Preline::TextArea
  TimePicker = Components::Preline::TimePicker
  Timeline = Components::Preline::Timeline
  Toast = Components::Preline::Toast
  ToggleCount = Components::Preline::ToggleCount
  TogglePassword = Components::Preline::TogglePassword
  Tooltip = Components::Preline::Tooltip
  TreeView = Components::Preline::TreeView
  Typography = Components::Preline::Typography
  PrelineComponent = Components::Preline::PrelineComponent
end

# Helper method to render Phlex components for testing
def render_phlex(component, &block)
  if block_given?
    component.call(&block)
  else
    component.call
  end
end

# Load custom matchers
Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |file| require file }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Include the render helper in all component specs
  config.include(Module.new do
    def render_phlex(component, &block)
      if block_given?
        component.call(&block)
      else
        component.call
      end
    end
  end, type: :component)
end

# Mock Rails form helpers for Form component
module Components
  module Preline
    class Form
      private
      
      def form_with(model: nil, url: nil, **options, &block)
        action = if model
          if model.persisted?
            "/#{model.model_name.route_key}/#{model.to_param}"
          else
            "/#{model.model_name.route_key}"
          end
        else
          url || "#"
        end
        
        method = options[:method] || :post
        local = options.fetch(:local, true)
        classes = options[:class].to_s
        id = options[:id]
        data_attrs = (options[:data] || {}).map { |k, v| "data-#{k.to_s.dasherize}=\"#{v}\"" }.join(' ')
        
        form_content = []
        
        # Opening form tag
        form_attrs = []
        form_attrs << "action=\"#{action}\""
        form_attrs << "method=\"#{method == :get ? 'get' : 'post'}\""
        form_attrs << "class=\"#{classes}\"" if classes.present?
        form_attrs << "id=\"#{id}\"" if id
        form_attrs << data_attrs if data_attrs.present?
        form_attrs << "data-remote=\"true\"" unless local
        
        form_content << "<form #{form_attrs.join(' ')}>"
        
        # CSRF token for non-GET requests
        if method != :get
          form_content << '<input type="hidden" name="authenticity_token" value="test-token" />'
        end
        
        # UTF-8 enforcer
        form_content << '<input type="hidden" name="utf8" value="✓" />'
        
        # Method override for non-POST/GET
        if method && ![:get, :post].include?(method)
          form_content << "<input type=\"hidden\" name=\"_method\" value=\"#{method}\" />"
        end
        
        # Yield form builder if block given
        if block
          form_builder = double('FormBuilder')
          allow(form_builder).to receive(:object).and_return(model) if model
          form_content << capture { block.call(form_builder) }
        end
        
        form_content << "</form>"
        
        form_content.join.html_safe
      end
    end
  end
end
