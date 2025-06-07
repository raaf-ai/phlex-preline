# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Flex, type: :component do
  describe '#view_template' do
    it 'renders basic flex container' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('<div')
      expect(output).to include('class="hs-flex hs-flex-shrink-0"')
      expect(output).to have_executed_code_path('Renders flex component')
      expect(output).to have_executed_code_path('Renders empty flex container')
      expect(output).to have_executed_code_path('Prevents flex shrink')
    end

    it 'renders flex with content' do
      component = described_class.new
      output = render_phlex(component) do
        "Flex content"
      end
      
      expect(output).to include('Flex content')
      expect(output).to have_executed_code_path('Renders flex with content')
    end

    it 'renders flex with direction' do
      component = described_class.new(direction: :col)
      output = render_phlex(component)
      
      expect(output).to include('hs-flex-col')
      expect(output).to have_executed_code_path('Adds flex direction')
    end

    it 'renders flex with wrap enabled' do
      component = described_class.new(wrap: true)
      output = render_phlex(component)
      
      expect(output).to include('hs-flex-wrap')
      expect(output).to have_executed_code_path('Adds flex wrap')
    end

    it 'renders flex with justify content' do
      component = described_class.new(justify: :between)
      output = render_phlex(component)
      
      expect(output).to include('hs-justify-between')
      expect(output).to have_executed_code_path('Adds justify content')
    end

    it 'renders flex with align items' do
      component = described_class.new(items: :center)
      output = render_phlex(component)
      
      expect(output).to include('hs-items-center')
      expect(output).to have_executed_code_path('Adds align items')
    end

    it 'renders flex with gap' do
      component = described_class.new(gap: 4)
      output = render_phlex(component)
      
      expect(output).to include('hs-gap-4')
      expect(output).to have_executed_code_path('Adds gap spacing')
    end

    it 'renders flex with grow enabled' do
      component = described_class.new(grow: true)
      output = render_phlex(component)
      
      expect(output).to include('hs-flex-grow')
      expect(output).to have_executed_code_path('Adds flex grow')
    end

    it 'renders flex with shrink enabled' do
      component = described_class.new(shrink: true)
      output = render_phlex(component)
      
      expect(output).not_to include('hs-flex-shrink-0')
    end

    it 'renders flex with multiple properties' do
      component = described_class.new(
        direction: :row,
        justify: :center,
        items: :center,
        gap: 3,
        wrap: true
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-flex')
      expect(output).to include('hs-flex-row')
      expect(output).to include('hs-flex-wrap')
      expect(output).to include('hs-justify-center')
      expect(output).to include('hs-items-center')
      expect(output).to include('hs-gap-3')
    end

    it 'accepts custom classes' do
      component = described_class.new(class: 'p-4 bg-gray-100')
      output = render_phlex(component)
      
      expect(output).to include('p-4 bg-gray-100')
    end

    it 'accepts HTML attributes' do
      component = described_class.new(
        id: 'flex-container',
        data: { test: 'value' },
        aria: { label: 'Flex container' }
      )
      output = render_phlex(component)
      
      expect(output).to include('id="flex-container"')
      expect(output).to include('data-test="value"')
      expect(output).to include('aria-label="Flex container"')
    end

    it 'passes through additional attributes' do
      component = described_class.new(
        role: 'navigation',
        style: 'min-height: 100px;'
      )
      output = render_phlex(component)
      
      expect(output).to include('role="navigation"')
      expect(output).to include('style="min-height: 100px;"')
    end
  end

  describe 'all direction variants' do
    %i[row col row-reverse col-reverse].each do |dir|
      it "renders flex with direction #{dir}" do
        component = described_class.new(direction: dir)
        output = render_phlex(component)
        
        expect(output).to include("hs-flex-#{dir}")
      end
    end
  end

  describe 'all justify variants' do
    %i[start center end between around evenly].each do |justify|
      it "renders flex with justify #{justify}" do
        component = described_class.new(justify: justify)
        output = render_phlex(component)
        
        expect(output).to include("hs-justify-#{justify}")
      end
    end
  end

  describe 'all items variants' do
    %i[start center end baseline stretch].each do |align|
      it "renders flex with items #{align}" do
        component = described_class.new(items: align)
        output = render_phlex(component)
        
        expect(output).to include("hs-items-#{align}")
      end
    end
  end

  describe 'gap values' do
    (0..12).each do |gap|
      it "renders flex with gap #{gap}" do
        component = described_class.new(gap: gap)
        output = render_phlex(component)
        
        expect(output).to include("hs-gap-#{gap}")
      end
    end
  end

  describe 'complex layout example' do
    it 'renders header layout with flex' do
      component = described_class.new(
        justify: :between,
        items: :center,
        class: 'p-4 border-b'
      )
      
      output = render_phlex(component) do |flex|
        flex.span { 'Logo' }
        flex.nav { 'Menu' }
      end
      
      expect(output).to include('hs-flex')
      expect(output).to include('hs-justify-between')
      expect(output).to include('hs-items-center')
      expect(output).to include('p-4 border-b')
      expect(output).to include('<span>Logo</span>')
      expect(output).to include('<nav>Menu</nav>')
    end
  end
end