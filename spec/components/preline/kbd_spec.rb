# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Kbd, type: :component do
  describe '#view_template' do
    it 'renders basic kbd with block content' do
      component = described_class.new
      output = render_phlex(component) do
        "Enter"
      end
      
      expect(output).to include('<kbd')
      expect(output).to include('class="hs-kbd')
      expect(output).to include('↵')
      expect(output).to have_executed_code_path('Renders kbd component')
      expect(output).to have_executed_code_path('Renders single key')
      expect(output).to have_executed_code_path('Renders default size')
    end

    it 'renders single key from keys array' do
      component = described_class.new(keys: ['Esc'])
      output = render_phlex(component)
      
      expect(output).to include('Esc')
      expect(output).to have_executed_code_path('Formats escape key')
    end

    it 'renders key combination' do
      component = described_class.new(keys: ['cmd', 'K'])
      output = render_phlex(component)
      
      expect(output).to include('⌘')
      expect(output).to include('K')
      expect(output).to include('+')
      expect(output).to have_executed_code_path('Renders key combination')
      expect(output).to have_executed_code_path('Formats command key')
      expect(output).to have_executed_code_path('Formats generic key')
    end

    it 'renders three-key combination' do
      component = described_class.new(keys: ['ctrl', 'shift', 'P'])
      output = render_phlex(component)
      
      expect(output).to include('Ctrl')
      expect(output).to include('⇧')
      expect(output).to include('P')
      expect(output.scan('+').length).to eq(2)
      expect(output).to have_executed_code_path('Formats control key')
      expect(output).to have_executed_code_path('Formats shift key')
    end
  end

  describe 'sizes' do
    it 'renders xs size' do
      component = described_class.new(size: :xs)
      output = render_phlex(component) { "A" }
      
      expect(output).to include('px-1 py-0.5 text-xs')
      expect(output).to have_executed_code_path('Renders xs size')
    end

    it 'renders sm size' do
      component = described_class.new(size: :sm)
      output = render_phlex(component) { "B" }
      
      expect(output).to include('px-1.5 py-0.5 text-xs')
      expect(output).to have_executed_code_path('Renders sm size')
    end

    it 'renders default size' do
      component = described_class.new(size: :default)
      output = render_phlex(component) { "C" }
      
      expect(output).to include('px-2 py-1 text-xs')
      expect(output).to have_executed_code_path('Renders default size')
    end

    it 'renders lg size' do
      component = described_class.new(size: :lg)
      output = render_phlex(component) { "D" }
      
      expect(output).to include('px-2.5 py-1.5 text-sm')
      expect(output).to have_executed_code_path('Renders lg size')
    end
  end

  describe 'key formatting' do
    it 'formats command key' do
      component = described_class.new(keys: ['cmd'])
      output = render_phlex(component)
      
      expect(output).to include('⌘')
    end

    it 'formats control key' do
      component = described_class.new(keys: ['ctrl'])
      output = render_phlex(component)
      
      expect(output).to include('Ctrl')
    end

    it 'formats option/alt key' do
      component = described_class.new(keys: ['alt'])
      output = render_phlex(component)
      
      expect(output).to include('⌥')
      expect(output).to have_executed_code_path('Formats option/alt key')
    end

    it 'formats shift key' do
      component = described_class.new(keys: ['shift'])
      output = render_phlex(component)
      
      expect(output).to include('⇧')
    end

    it 'formats enter key' do
      component = described_class.new(keys: ['enter'])
      output = render_phlex(component)
      
      expect(output).to include('↵')
      expect(output).to have_executed_code_path('Formats enter key')
    end

    it 'formats escape key variants' do
      ['escape', 'esc'].each do |key|
        component = described_class.new(keys: [key])
        output = render_phlex(component)
        
        expect(output).to include('Esc')
      end
    end

    it 'formats space key' do
      component = described_class.new(keys: ['space'])
      output = render_phlex(component)
      
      expect(output).to include('Space')
      expect(output).to have_executed_code_path('Formats space key')
    end

    it 'formats tab key' do
      component = described_class.new(keys: ['tab'])
      output = render_phlex(component)
      
      expect(output).to include('Tab')
      expect(output).to have_executed_code_path('Formats tab key')
    end

    it 'formats arrow keys' do
      arrows = { 'up' => '↑', 'down' => '↓', 'left' => '←', 'right' => '→' }
      
      arrows.each do |key, symbol|
        component = described_class.new(keys: [key])
        output = render_phlex(component)
        
        expect(output).to include(symbol)
        expect(output).to have_executed_code_path("Formats #{key} arrow")
      end
    end

    it 'formats delete key' do
      component = described_class.new(keys: ['delete'])
      output = render_phlex(component)
      
      expect(output).to include('Del')
      expect(output).to have_executed_code_path('Formats delete key')
    end

    it 'capitalizes generic keys' do
      component = described_class.new(keys: ['f1'])
      output = render_phlex(component)
      
      expect(output).to include('F1')
      expect(output).to have_executed_code_path('Formats generic key')
    end
  end

  describe 'styling' do
    it 'has default kbd styling' do
      component = described_class.new
      output = render_phlex(component) { "K" }
      
      expect(output).to include('inline-flex')
      expect(output).to include('items-center')
      expect(output).to include('justify-center')
      expect(output).to include('text-gray-800')
      expect(output).to include('bg-gray-100')
      expect(output).to include('border')
      expect(output).to include('border-gray-200')
      expect(output).to include('rounded')
      expect(output).to include('font-mono')
      expect(output).to include('leading-none')
    end

    it 'accepts custom classes' do
      component = described_class.new(
        class: 'bg-blue-100 border-blue-300 text-blue-800'
      )
      output = render_phlex(component) { "⌘" }
      
      expect(output).to include('bg-blue-100')
      expect(output).to include('border-blue-300')
      expect(output).to include('text-blue-800')
    end

    it 'accepts HTML attributes' do
      component = described_class.new(
        id: 'shortcut-key',
        data: { shortcut: 'save' }
      )
      output = render_phlex(component) { "S" }
      
      expect(output).to include('id="shortcut-key"')
      expect(output).to include('data-shortcut="save"')
    end
  end

  describe 'common use cases' do
    it 'renders save shortcut' do
      component = described_class.new(keys: ['cmd', 'S'])
      output = render_phlex(component)
      
      expect(output).to include('⌘')
      expect(output).to include('+')
      expect(output).to include('S')
    end

    it 'renders copy shortcut' do
      component = described_class.new(keys: ['ctrl', 'C'])
      output = render_phlex(component)
      
      expect(output).to include('Ctrl')
      expect(output).to include('+')
      expect(output).to include('C')
    end

    it 'renders in text context' do
      output = '<p>Press ' + render_phlex(described_class.new { "Enter" }) + ' to submit</p>'
      
      expect(output).to include('<p>Press')
      expect(output).to include('<kbd')
      expect(output).to include('↵')
      expect(output).to include('to submit</p>')
    end

    it 'renders help text with multiple shortcuts' do
      save_key = described_class.new(keys: ['cmd', 'S'])
      quit_key = described_class.new(keys: ['cmd', 'Q'])
      
      save_output = render_phlex(save_key)
      quit_output = render_phlex(quit_key)
      
      full_text = "Press #{save_output} to save or #{quit_output} to quit"
      
      expect(full_text).to include('⌘')
      expect(full_text).to include('S')
      expect(full_text).to include('Q')
      expect(full_text).to include('to save or')
      expect(full_text).to include('to quit')
    end
  end
end