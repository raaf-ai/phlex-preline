# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Pagination, type: :component do
  describe '#view_template' do
    it 'renders nothing when total_pages is 1 or less' do
      component = described_class.new(current_page: 1, total_pages: 1)
      output = render_phlex(component)
      expect(output).to be_empty
    end

    it 'renders basic pagination with page numbers' do
      component = described_class.new(
        current_page: 3,
        total_pages: 5,
        path: '/items'
      )
      output = render_phlex(component)

      expect(output).to include('hs-pagination')
      expect(output).to have_executed_code_path('Renders pagination navigation with page controls')
      expect(output).to have_executed_code_path('Renders numbered page links with current page highlighted')
    end

    it 'renders with pagination info' do
      component = described_class.new(
        current_page: 2,
        total_pages: 5,
        total_items: 47,
        per_page: 10,
        show_info: true,
        path: '/items'
      )
      output = render_phlex(component)

      expect(output).to include('hs-pagination-info')
      expect(output).to have_executed_code_path('Renders pagination info showing item count and range')
    end

    it 'renders first and last page buttons' do
      component = described_class.new(
        current_page: 3,
        total_pages: 10,
        show_first_last: true,
        path: '/items'
      )
      output = render_phlex(component)

      expect(output).to include('fa-angle-double-left')
      expect(output).to include('fa-angle-double-right')
      expect(output).to have_executed_code_path('Renders first page navigation button with double arrow')
      expect(output).to have_executed_code_path('Renders last page navigation button with double arrow')
    end

    it 'renders previous and next buttons' do
      component = described_class.new(
        current_page: 3,
        total_pages: 5,
        show_prev_next: true,
        path: '/items'
      )
      output = render_phlex(component)

      expect(output).to include('fa-angle-left')
      expect(output).to include('fa-angle-right')
      expect(output).to have_executed_code_path('Renders previous page navigation button')
      expect(output).to have_executed_code_path('Renders next page navigation button')
    end

    it 'renders disabled previous button on first page' do
      component = described_class.new(
        current_page: 1,
        total_pages: 5,
        path: '/items'
      )
      output = render_phlex(component)

      expect(output).to include('hs-pagination-disabled')
      expect(output).to have_executed_code_path('Renders disabled previous button at first page')
    end

    it 'renders disabled next button on last page' do
      component = described_class.new(
        current_page: 5,
        total_pages: 5,
        path: '/items'
      )
      output = render_phlex(component)

      expect(output).to include('hs-pagination-disabled')
      expect(output).to have_executed_code_path('Renders disabled next button at last page')
    end

    it 'renders current page with active styling' do
      component = described_class.new(
        current_page: 3,
        total_pages: 5,
        path: '/items'
      )
      output = render_phlex(component)

      expect(output).to include('hs-pagination-active')
      expect(output).to include('aria-current="page"')
      expect(output).to have_executed_code_path('Renders current page number with active styling')
    end

    it 'renders clickable page links' do
      component = described_class.new(
        current_page: 3,
        total_pages: 5,
        path: '/items'
      )
      output = render_phlex(component)

      expect(output).to include('href="/items?page=1"')
      expect(output).to include('href="/items?page=2"')
      expect(output).to have_executed_code_path('Renders clickable page number link')
    end

    it 'renders ellipsis for gaps in page numbers' do
      component = described_class.new(
        current_page: 5,
        total_pages: 20,
        window: 2,
        outer_window: 1,
        path: '/items'
      )
      output = render_phlex(component)

      expect(output).to include('hs-pagination-gap')
      expect(output).to include('hs-pagination-ellipsis')
      expect(output).to have_executed_code_path('Renders ellipsis indicator for skipped page numbers')
    end

    it 'renders clickable previous and next buttons when not at bounds' do
      component = described_class.new(
        current_page: 3,
        total_pages: 5,
        path: '/items'
      )
      output = render_phlex(component)

      expect(output).to include('href="/items?page=2"')
      expect(output).to include('href="/items?page=4"')
      expect(output).to have_executed_code_path('Renders clickable previous button with page link')
      expect(output).to have_executed_code_path('Renders clickable next button with page link')
    end
  end
end