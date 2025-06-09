# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::ButtonGroup, type: :component do
  describe '#view_template' do
    it 'renders basic button group' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('hs-button-group')
      expect(output).to have_executed_code_path('Renders button group component')
    end

    it 'renders button group with yielding interface' do
      component = described_class.new
      output = render_phlex(component) do |group|
        group.button(text: 'Left', variant: :secondary)
        group.button(text: 'Middle', variant: :secondary)
        group.button(text: 'Right', variant: :secondary)
      end
      
      expect(output).to include('hs-button-group')
      expect(output).to include('Left')
      expect(output).to include('Middle')
      expect(output).to include('Right')
      expect(output).to include('rounded-r-none') # first button
      expect(output).to include('rounded-l-none') # last button
      expect(output).to include('rounded-none') # middle button
    end

    it 'renders button group with icons using yielding interface' do
      component = described_class.new(size: :sm)
      output = render_phlex(component) do |group|
        group.button(text: 'Edit', icon: 'edit', variant: :primary)
        group.button(text: 'Delete', icon: 'trash', variant: :danger)
      end
      
      expect(output).to include('Edit')
      expect(output).to include('Delete')
      expect(output).to include('fa-edit')
      expect(output).to include('fa-trash')
      expect(output).to include('rounded-r-none') # first button styling
      expect(output).to include('rounded-l-none') # second button styling
    end

    it 'renders segmented control style with yielding interface' do
      component = described_class.new
      output = render_phlex(component) do |group|
        group.button(text: 'Day', variant: :primary)
        group.button(text: 'Week', variant: :secondary)
        group.button(text: 'Month', variant: :secondary)
        group.button(text: 'Year', variant: :secondary)
      end
      
      expect(output).to include('Day')
      expect(output).to include('Week')
      expect(output).to include('Month')
      expect(output).to include('Year')
    end

    it 'supports legacy pattern with block content' do
      component = described_class.new
      output = render_phlex(component) do
        'Custom content'
      end
      
      expect(output).to include('hs-button-group')
      expect(output).to include('Custom content')
    end

    it 'renders with custom size and variant' do
      component = described_class.new(size: :lg, variant: :primary)
      output = render_phlex(component) do |group|
        group.button(text: 'Large Button')
      end
      
      expect(output).to include('Large Button')
    end

    it 'renders with custom CSS classes' do
      component = described_class.new(class: 'custom-group')
      output = render_phlex(component) do |group|
        group.button(text: 'Button')
      end
      
      expect(output).to include('custom-group')
    end
  end
  
  describe 'convenience methods' do
    it 'renders icon-only buttons' do
      component = described_class.new
      output = render_phlex(component) do |group|
        group.icon_button(icon: 'edit', title: 'Edit')
        group.icon_button(icon: 'trash', title: 'Delete', variant: :danger)
      end
      
      expect(output).to include('fa-edit')
      expect(output).to include('fa-trash')
      expect(output).to include('title="Edit"')
      expect(output).to include('aria-label="Edit"')
      expect(output).to include('title="Delete"')
      expect(output).to include('aria-label="Delete"')
    end

    it 'renders save/cancel button pair' do
      component = described_class.new
      output = render_phlex(component) do |group|
        group.save_cancel
      end
      
      expect(output).to include('Save')
      expect(output).to include('Cancel')
      expect(output).to include('fa-check')
      expect(output).to include('fa-times')
    end

    it 'renders save/cancel with custom text and attributes' do
      component = described_class.new
      output = render_phlex(component) do |group|
        group.save_cancel(
          save_text: 'Apply',
          cancel_text: 'Discard',
          save_attrs: { data: { action: 'save' } },
          cancel_attrs: { data: { dismiss: 'modal' } }
        )
      end
      
      expect(output).to include('Apply')
      expect(output).to include('Discard')
      expect(output).to include('data-action="save"')
      expect(output).to include('data-dismiss="modal"')
    end

    it 'renders edit/delete button pair' do
      component = described_class.new
      output = render_phlex(component) do |group|
        group.edit_delete
      end
      
      expect(output).to include('Edit')
      expect(output).to include('Delete')
      expect(output).to include('fa-edit')
      expect(output).to include('fa-trash')
    end

    it 'renders CRUD action buttons' do
      component = described_class.new
      output = render_phlex(component) do |group|
        group.crud_actions
      end
      
      expect(output).to include('Create')
      expect(output).to include('View')
      expect(output).to include('Edit')
      expect(output).to include('Delete')
      expect(output).to include('fa-plus')
      expect(output).to include('fa-eye')
      expect(output).to include('fa-edit')
      expect(output).to include('fa-trash')
    end

    it 'renders selected CRUD actions with custom labels' do
      component = described_class.new
      output = render_phlex(component) do |group|
        group.crud_actions(
          actions: [:create, :update],
          labels: { create: 'New Item', update: 'Modify' }
        )
      end
      
      expect(output).to include('New Item')
      expect(output).to include('Modify')
      expect(output).not_to include('View')
      expect(output).not_to include('Delete')
    end

    it 'renders toggle group' do
      component = described_class.new
      output = render_phlex(component) do |group|
        group.toggle_group(
          name: 'view-mode',
          options: [
            { text: 'List', value: 'list', selected: true },
            { text: 'Grid', value: 'grid' },
            { text: 'Cards', value: 'cards' }
          ]
        )
      end
      
      expect(output).to include('List')
      expect(output).to include('Grid')
      expect(output).to include('Cards')
      expect(output).to include('data-toggle="button"')
      expect(output).to include('data-value="list"')
      expect(output).to include('data-value="grid"')
      expect(output).to include('data-value="cards"')
      expect(output).to include('data-name="view-mode"')
    end

    it 'renders toolbar with icon buttons' do
      component = described_class.new
      output = render_phlex(component) do |group|
        group.toolbar(
          tools: [
            { icon: 'bold', title: 'Bold' },
            { icon: 'italic', title: 'Italic' },
            { icon: 'underline', title: 'Underline', action: 'format("underline")' }
          ]
        )
      end
      
      expect(output).to include('fa-bold')
      expect(output).to include('fa-italic')
      expect(output).to include('fa-underline')
      expect(output).to include('title="Bold"')
      expect(output).to include('title="Italic"')
      expect(output).to include('title="Underline"')
      expect(output).to include('data-action="format(&quot;underline&quot;)"')
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new }.not_to raise_error
    end

    it 'accepts size and variant parameters' do
      expect {
        described_class.new(size: :sm, variant: :primary)
      }.not_to raise_error
    end

    it 'accepts custom classes and attributes' do
      expect {
        described_class.new(
          class: 'custom',
          id: 'my-group',
          data: { testid: 'button-group' }
        )
      }.not_to raise_error
    end
    
    it 'validates size values' do
      expect { described_class.new(size: :invalid) }.to raise_error(ArgumentError, /Invalid size/)
    end

    it 'validates variant values' do
      expect { described_class.new(variant: :invalid) }.to raise_error(ArgumentError, /Invalid variant/)
    end
  end
end
