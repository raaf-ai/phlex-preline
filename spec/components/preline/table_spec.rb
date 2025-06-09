# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Table, type: :component do
  describe '#view_template' do
    it 'renders basic table' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('hs-table')
      expect(output).to include('flex flex-col')
      expect(output).to include('overflow-x-auto')
      expect(output).to include('min-w-full')
      expect(output).to have_executed_code_path('Renders table component')
      expect(output).to have_executed_code_path('Renders default size table')
    end
    
    it 'renders hoverable table' do
      component = described_class.new(hoverable: true)
      output = render_phlex(component)
      
      expect(output).to include('hs-table-hover')
      expect(output).to have_executed_code_path('Renders hoverable table rows')
    end
    
    it 'renders striped table' do
      component = described_class.new(striped: true)
      output = render_phlex(component)
      
      expect(output).to include('hs-table-striped')
      expect(output).to have_executed_code_path('Renders striped table rows')
    end
    
    it 'renders different table sizes' do
      %i[sm default lg].each do |size|
        component = described_class.new(size: size)
        output = render_phlex(component)
        
        if size == :sm
          expect(output).to include('hs-table-sm')
          expect(output).to have_executed_code_path('Renders small size table')
        elsif size == :lg
          expect(output).to include('hs-table-lg')
          expect(output).to have_executed_code_path('Renders large size table')
        else
          expect(output).to have_executed_code_path('Renders default size table')
        end
      end
    end
    
    it 'renders table with all options' do
      component = described_class.new(
        hoverable: true,
        striped: true,
        size: :lg,
        class: 'custom-table',
        data: { test: 'value' }
      )
      output = render_phlex(component) do
        'Table content'
      end
      
      expect(output).to include('hs-table-hover')
      expect(output).to include('hs-table-striped')
      expect(output).to include('hs-table-lg')
      expect(output).to include('custom-table')
      expect(output).to include('data-test="value"')
      expect(output).to include('Table content')
      expect(output).to have_executed_code_path('Renders hoverable table rows')
      expect(output).to have_executed_code_path('Renders striped table rows')
      expect(output).to have_executed_code_path('Renders large size table')
    end
    
    it 'renders table with nested structure' do
      component = described_class.new
      output = render_phlex(component) do |table|
        table.render Preline::TableHead.new do |thead|
          thead.render Preline::TableRow.new do |tr|
            tr.render Preline::TableHeaderCell.new { 'Name' }
            tr.render Preline::TableHeaderCell.new { 'Email' }
          end
        end
        table.render Preline::TableBody.new do |tbody|
          tbody.render Preline::TableRow.new do |tr|
            tr.render Preline::TableCell.new { 'John' }
            tr.render Preline::TableCell.new { 'john@example.com' }
          end
        end
      end
      
      expect(output).to include('<thead')
      expect(output).to include('<tbody')
      expect(output).to include('<tr')
      expect(output).to include('<th')
      expect(output).to include('<td')
      expect(output).to include('Name')
      expect(output).to include('Email')
      expect(output).to include('John')
      expect(output).to include('john@example.com')
    end
  end
  
  describe 'TableHead component' do
    it 'renders table head' do
      component = Preline::TableHead.new
      output = render_phlex(component)
      
      expect(output).to include('<thead')
      expect(output).to include('hs-table-head')
      expect(output).to have_executed_code_path('Renders table head component')
    end
    
    it 'renders with custom attributes' do
      component = Preline::TableHead.new(class: 'custom-head', id: 'table-head')
      output = render_phlex(component)
      
      expect(output).to include('custom-head')
      expect(output).to include('id="table-head"')
    end
  end
  
  describe 'TableBody component' do
    it 'renders table body' do
      component = Preline::TableBody.new
      output = render_phlex(component)
      
      expect(output).to include('<tbody')
      expect(output).to include('hs-table-body')
      expect(output).to include('divide-y divide-gray-200')
      expect(output).to have_executed_code_path('Renders table body component')
    end
    
    it 'renders with custom attributes' do
      component = Preline::TableBody.new(class: 'custom-body')
      output = render_phlex(component)
      
      expect(output).to include('custom-body')
    end
  end
  
  describe 'TableRow component' do
    it 'renders table row' do
      component = Preline::TableRow.new
      output = render_phlex(component)
      
      expect(output).to include('<tr')
      expect(output).to have_executed_code_path('Renders table row component')
    end
    
    it 'renders with custom attributes' do
      component = Preline::TableRow.new(class: 'hover:bg-gray-50', data: { id: '123' })
      output = render_phlex(component)
      
      expect(output).to include('hover:bg-gray-50')
      expect(output).to include('data-id="123"')
    end
  end
  
  describe 'TableHeaderCell component' do
    it 'renders table header cell with default column scope' do
      component = Preline::TableHeaderCell.new
      output = render_phlex(component) { 'Header' }
      
      expect(output).to include('<th')
      expect(output).to include('scope="col"')
      expect(output).to include('hs-table-header-cell')
      expect(output).to include('Header')
      expect(output).to have_executed_code_path('Renders table header cell component')
      expect(output).to have_executed_code_path('Renders column scope header cell')
    end
    
    it 'renders with row scope' do
      component = Preline::TableHeaderCell.new(scope: 'row')
      output = render_phlex(component) { 'Row Header' }
      
      expect(output).to include('scope="row"')
      expect(output).to include('Row Header')
      expect(output).to have_executed_code_path('Renders row scope header cell')
    end
    
    it 'renders with custom styling' do
      component = Preline::TableHeaderCell.new(class: 'text-center')
      output = render_phlex(component)
      
      expect(output).to include('text-center')
      expect(output).to include('px-6 py-3')
      expect(output).to include('text-start text-xs font-medium text-gray-500 uppercase')
    end
  end
  
  describe 'TableCell component' do
    it 'renders table cell' do
      component = Preline::TableCell.new
      output = render_phlex(component) { 'Cell content' }
      
      expect(output).to include('<td')
      expect(output).to include('hs-table-cell')
      expect(output).to include('Cell content')
      expect(output).to include('px-6 py-4')
      expect(output).to include('whitespace-nowrap text-sm text-gray-800')
      expect(output).to have_executed_code_path('Renders table cell component')
    end
    
    it 'renders with custom attributes' do
      component = Preline::TableCell.new(class: 'font-bold', colspan: '2')
      output = render_phlex(component)
      
      expect(output).to include('font-bold')
      expect(output).to include('colspan="2"')
    end
  end
  
  describe 'initialization validation' do
    it 'validates size inclusion' do
      expect { described_class.new(size: :invalid) }.to raise_error(Phlex::Preline::InvalidParameterError, /Invalid size/)
    end
    
    it 'validates boolean parameters' do
      expect { described_class.new(hoverable: 'yes') }.to raise_error(Phlex::Preline::InvalidParameterError)
      expect { described_class.new(striped: 'true') }.to raise_error(Phlex::Preline::InvalidParameterError)
    end
    
    it 'validates header cell scope' do
      expect { Preline::TableHeaderCell.new(scope: 'invalid') }.to raise_error(Phlex::Preline::InvalidParameterError, /Invalid scope/)
    end
  end
  
  describe 'integration tests' do
    it 'renders complete table with data' do
      users = [
        { name: 'Alice', email: 'alice@example.com', status: 'Active' },
        { name: 'Bob', email: 'bob@example.com', status: 'Inactive' }
      ]
      
      component = described_class.new(striped: true, hoverable: true)
      output = render_phlex(component) do |table|
        table.render Preline::TableHead.new do |thead|
          thead.render Preline::TableRow.new do |tr|
            tr.render Preline::TableHeaderCell.new { 'Name' }
            tr.render Preline::TableHeaderCell.new { 'Email' }
            tr.render Preline::TableHeaderCell.new { 'Status' }
          end
        end
        table.render Preline::TableBody.new do |tbody|
          users.each do |user|
            tbody.render Preline::TableRow.new do |tr|
              tr.render Preline::TableCell.new { user[:name] }
              tr.render Preline::TableCell.new { user[:email] }
              tr.render Preline::TableCell.new { user[:status] }
            end
          end
        end
      end
      
      # Check structure
      expect(output).to include('hs-table-striped')
      expect(output).to include('hs-table-hover')
      
      # Check headers
      expect(output).to include('<th')
      expect(output).to include('Name')
      expect(output).to include('Email')
      expect(output).to include('Status')
      
      # Check data
      expect(output).to include('Alice')
      expect(output).to include('alice@example.com')
      expect(output).to include('Active')
      expect(output).to include('Bob')
      expect(output).to include('bob@example.com')
      expect(output).to include('Inactive')
      
      # Check code paths
      expect(output).to have_executed_code_path('Renders striped table rows')
      expect(output).to have_executed_code_path('Renders hoverable table rows')
      expect(output).to have_executed_code_path('Renders table head component')
      expect(output).to have_executed_code_path('Renders table body component')
      expect(output).to have_executed_code_path('Renders table row component')
      expect(output).to have_executed_code_path('Renders table header cell component')
      expect(output).to have_executed_code_path('Renders table cell component')
    end
  end

  describe 'yielding interface pattern' do
    it 'yields self when block is given' do
      component = described_class.new
      yielded_object = nil
      
      render_phlex(component) do |table|
        yielded_object = table
      end
      
      expect(yielded_object).to eq(component)
    end

    it 'renders table using yielding interface' do
      component = described_class.new(striped: true)
      output = render_phlex(component) do |table|
        table.head do |head|
          head.row do |row|
            row.header_cell { 'Name' }
            row.header_cell { 'Email' }
          end
        end
        table.body do |body|
          body.row do |row|
            row.cell { 'John Doe' }
            row.cell { 'john@example.com' }
          end
        end
      end
      
      expect(output).to include('Name')
      expect(output).to include('Email')
      expect(output).to include('John Doe')
      expect(output).to include('john@example.com')
      expect(output).to include('hs-table-striped')
      expect(output).to include('hs-table-head')
      expect(output).to include('hs-table-body')
    end

    it 'supports mixed usage of yielding interface and direct components' do
      component = described_class.new
      output = render_phlex(component) do |table|
        table.head do |head|
          head.row do |row|
            row.header_cell { 'Via Interface' }
          end
        end
        table.render Preline::TableBody.new do |body|
          body.render Preline::TableRow.new do |row|
            row.render Preline::TableCell.new { 'Direct Component' }
          end
        end
      end
      
      expect(output).to include('Via Interface')
      expect(output).to include('Direct Component')
    end

    it 'passes attributes through yielding interface' do
      component = described_class.new
      output = render_phlex(component) do |table|
        table.head(class: 'custom-head') do |head|
          head.row(id: 'header-row') do |row|
            row.header_cell(class: 'custom-header-cell') { 'Header' }
          end
        end
        table.body(class: 'custom-body') do |body|
          body.row(data: { id: '123' }) do |row|
            row.cell(class: 'custom-cell') { 'Cell' }
          end
        end
      end
      
      expect(output).to include('custom-head')
      expect(output).to include('header-row')
      expect(output).to include('custom-header-cell')
      expect(output).to include('custom-body')
      expect(output).to include('data-id="123"')
      expect(output).to include('custom-cell')
    end
  end
end