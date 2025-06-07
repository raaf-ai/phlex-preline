# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Grid, type: :component do
  describe '#view_template' do
    it 'renders basic grid with default columns' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('<div')
      expect(output).to include('class="hs-grid hs-grid-cols-1 hs-gap-4"')
      expect(output).to have_executed_code_path('Renders grid component')
      expect(output).to have_executed_code_path('Renders empty grid container')
      expect(output).to have_executed_code_path('Adds grid gap')
    end

    it 'renders grid with content' do
      component = described_class.new
      output = render_phlex(component) do
        "Grid content"
      end
      
      expect(output).to include('Grid content')
      expect(output).to have_executed_code_path('Renders grid with content')
    end

    it 'renders grid with custom columns' do
      component = described_class.new(cols: 3)
      output = render_phlex(component)
      
      expect(output).to include('hs-grid-cols-3')
    end

    it 'renders grid with responsive breakpoints' do
      component = described_class.new(
        cols: 1,
        sm: 2,
        md: 3,
        lg: 4,
        xl: 6
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-grid-cols-1')
      expect(output).to include('sm:hs-grid-cols-2')
      expect(output).to include('md:hs-grid-cols-3')
      expect(output).to include('lg:hs-grid-cols-4')
      expect(output).to include('xl:hs-grid-cols-6')
      expect(output).to have_executed_code_path('Adds sm breakpoint columns')
      expect(output).to have_executed_code_path('Adds md breakpoint columns')
      expect(output).to have_executed_code_path('Adds lg breakpoint columns')
      expect(output).to have_executed_code_path('Adds xl breakpoint columns')
    end

    it 'renders grid with custom gap' do
      component = described_class.new(gap: 8)
      output = render_phlex(component)
      
      expect(output).to include('hs-gap-8')
    end

    it 'renders grid without gap when gap is 0' do
      component = described_class.new(gap: 0)
      output = render_phlex(component)
      
      expect(output).not_to include('hs-gap-')
    end

    it 'renders grid with align items' do
      component = described_class.new(align_items: :center)
      output = render_phlex(component)
      
      expect(output).to include('hs-items-center')
      expect(output).to have_executed_code_path('Adds align items')
    end

    it 'renders grid with justify items' do
      component = described_class.new(justify_items: :center)
      output = render_phlex(component)
      
      expect(output).to include('hs-justify-items-center')
      expect(output).to have_executed_code_path('Adds justify items')
    end

    it 'accepts custom classes' do
      component = described_class.new(class: 'p-4 bg-gray-50')
      output = render_phlex(component)
      
      expect(output).to include('p-4 bg-gray-50')
    end

    it 'accepts HTML attributes' do
      component = described_class.new(
        id: 'main-grid',
        data: { grid: 'true' },
        aria: { label: 'Main grid' }
      )
      output = render_phlex(component)
      
      expect(output).to include('id="main-grid"')
      expect(output).to include('data-grid="true"')
      expect(output).to include('aria-label="Main grid"')
    end

    it 'passes through additional attributes' do
      component = described_class.new(
        role: 'list',
        style: 'max-width: 1200px;'
      )
      output = render_phlex(component)
      
      expect(output).to include('role="list"')
      expect(output).to include('style="max-width: 1200px;"')
    end
  end

  describe 'column values' do
    (1..12).each do |cols|
      it "renders grid with #{cols} columns" do
        component = described_class.new(cols: cols)
        output = render_phlex(component)
        
        expect(output).to include("hs-grid-cols-#{cols}")
      end
    end
  end

  describe 'align items variants' do
    %i[start center end baseline stretch].each do |align|
      it "renders grid with align-items #{align}" do
        component = described_class.new(align_items: align)
        output = render_phlex(component)
        
        expect(output).to include("hs-items-#{align}")
      end
    end
  end

  describe 'justify items variants' do
    %i[start center end stretch].each do |justify|
      it "renders grid with justify-items #{justify}" do
        component = described_class.new(justify_items: justify)
        output = render_phlex(component)
        
        expect(output).to include("hs-justify-items-#{justify}")
      end
    end
  end

  describe 'gap values' do
    (0..12).each do |gap|
      it "renders grid with gap #{gap}" do
        component = described_class.new(gap: gap)
        output = render_phlex(component)
        
        if gap > 0
          expect(output).to include("hs-gap-#{gap}")
        else
          expect(output).not_to include('hs-gap-')
        end
      end
    end
  end

  describe 'partial responsive configuration' do
    it 'renders grid with only some breakpoints' do
      component = described_class.new(
        cols: 1,
        md: 2,
        lg: 3
      )
      output = render_phlex(component)
      
      expect(output).to include('hs-grid-cols-1')
      expect(output).not_to include('sm:hs-grid-cols')
      expect(output).to include('md:hs-grid-cols-2')
      expect(output).to include('lg:hs-grid-cols-3')
      expect(output).not_to include('xl:hs-grid-cols')
    end
  end

  describe 'complex layout example' do
    it 'renders card grid layout' do
      component = described_class.new(
        cols: 1,
        md: 2,
        lg: 3,
        gap: 6,
        align_items: :stretch,
        class: 'p-6'
      )
      
      output = render_phlex(component) do |grid|
        grid.div { "Card 1" }
        grid.div { "Card 2" }
        grid.div { "Card 3" }
      end
      
      expect(output).to include('hs-grid')
      expect(output).to include('hs-grid-cols-1')
      expect(output).to include('md:hs-grid-cols-2')
      expect(output).to include('lg:hs-grid-cols-3')
      expect(output).to include('hs-gap-6')
      expect(output).to include('hs-items-stretch')
      expect(output).to include('p-6')
      expect(output).to include('<div>Card 1</div>')
      expect(output).to include('<div>Card 2</div>')
      expect(output).to include('<div>Card 3</div>')
    end
  end
end