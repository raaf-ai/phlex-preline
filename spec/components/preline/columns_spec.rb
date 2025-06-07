# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Columns, type: :component do
  describe '#view_template' do
    it 'renders basic columns with default settings' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('<div')
      expect(output).to include('class="hs-columns columns-2 gap-4"')
      expect(output).to have_executed_code_path('Renders columns component')
      expect(output).to have_executed_code_path('Renders empty columns')
      expect(output).to have_executed_code_path('Adds column gap')
    end

    it 'renders columns with content' do
      component = described_class.new
      output = render_phlex(component) do
        "Column content"
      end
      
      expect(output).to include('Column content')
      expect(output).to have_executed_code_path('Renders columns with content')
    end

    it 'renders columns with custom column count' do
      component = described_class.new(cols: 3)
      output = render_phlex(component)
      
      expect(output).to include('columns-3')
    end

    it 'renders columns with custom gap' do
      component = described_class.new(gap: 8)
      output = render_phlex(component)
      
      expect(output).to include('gap-8')
    end

    it 'renders columns without gap when gap is 0' do
      component = described_class.new(gap: 0)
      output = render_phlex(component)
      
      expect(output).not_to include('gap-')
    end

    it 'renders columns with responsive breakpoints' do
      component = described_class.new(
        cols: 1,
        responsive: { sm: 2, md: 3, lg: 4 }
      )
      output = render_phlex(component)
      
      expect(output).to include('columns-1')
      expect(output).to include('sm:columns-2')
      expect(output).to include('md:columns-3')
      expect(output).to include('lg:columns-4')
      expect(output).to have_executed_code_path('Adds responsive columns')
    end

    it 'accepts custom classes' do
      component = described_class.new(class: 'my-columns text-sm')
      output = render_phlex(component)
      
      expect(output).to include('my-columns text-sm')
    end

    it 'accepts HTML attributes' do
      component = described_class.new(
        id: 'article-columns',
        data: { layout: 'columns' },
        aria: { label: 'Article columns' }
      )
      output = render_phlex(component)
      
      expect(output).to include('id="article-columns"')
      expect(output).to include('data-layout="columns"')
      expect(output).to include('aria-label="Article columns"')
    end

    it 'passes through additional attributes' do
      component = described_class.new(
        role: 'list',
        style: 'max-width: 800px;'
      )
      output = render_phlex(component)
      
      expect(output).to include('role="list"')
      expect(output).to include('style="max-width: 800px;"')
    end
  end

  describe 'column counts' do
    (1..12).each do |cols|
      it "renders #{cols} columns" do
        component = described_class.new(cols: cols)
        output = render_phlex(component)
        
        expect(output).to include("columns-#{cols}")
      end
    end
  end

  describe 'gap values' do
    (0..12).each do |gap|
      it "renders gap-#{gap}" do
        component = described_class.new(gap: gap)
        output = render_phlex(component)
        
        if gap > 0
          expect(output).to include("gap-#{gap}")
        else
          expect(output).not_to include('gap-')
        end
      end
    end
  end

  describe 'responsive breakpoints' do
    %i[sm md lg xl 2xl].each do |breakpoint|
      it "supports #{breakpoint} breakpoint" do
        component = described_class.new(
          cols: 1,
          responsive: { breakpoint => 4 }
        )
        output = render_phlex(component)
        
        expect(output).to include("#{breakpoint}:columns-4")
      end
    end
  end

  describe 'complex layouts' do
    it 'renders article layout with responsive columns' do
      component = described_class.new(
        cols: 1,
        responsive: { md: 2, lg: 3 },
        gap: 6,
        class: 'article-content'
      )
      output = render_phlex(component) do |c|
        c.p { "Article paragraph 1" }
        c.p { "Article paragraph 2" }
      end
      
      expect(output).to include('columns-1')
      expect(output).to include('md:columns-2')
      expect(output).to include('lg:columns-3')
      expect(output).to include('gap-6')
      expect(output).to include('article-content')
      expect(output).to include('<p>Article paragraph 1</p>')
    end

    it 'renders card gallery layout' do
      component = described_class.new(
        cols: 4,
        gap: 4,
        class: 'gallery'
      )
      output = render_phlex(component) do
        (1..8).map { |i| "<div class='card'>Card #{i}</div>" }.join
      end
      
      expect(output).to include('columns-4')
      expect(output).to include('gap-4')
      expect(output).to include('gallery')
      expect(output).to include('Card 1')
      expect(output).to include('Card 8')
    end
  end
end

RSpec.describe Components::Preline::ColumnBreak, type: :component do
  describe '#view_template' do
    it 'renders column break' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('<div')
      expect(output).to include('class="break-after-column"')
      expect(output).to have_executed_code_path('Renders column break')
    end

    it 'accepts custom classes' do
      component = described_class.new(class: 'my-break')
      output = render_phlex(component)
      
      expect(output).to include('break-after-column')
      expect(output).to include('my-break')
    end

    it 'accepts HTML attributes' do
      component = described_class.new(
        id: 'section-break',
        data: { section: 'end' }
      )
      output = render_phlex(component)
      
      expect(output).to include('id="section-break"')
      expect(output).to include('data-section="end"')
    end
  end

  describe 'usage with Columns' do
    it 'works within columns layout' do
      columns = Preline::Columns.new(cols: 2)
      output = render_phlex(columns) do
        content = []
        content << "<h3>Section 1</h3>"
        content << "<p>Content 1</p>"
        
        break_component = described_class.new
        content << render_phlex(break_component)
        
        content << "<h3>Section 2</h3>"
        content << "<p>Content 2</p>"
        
        content.join
      end
      
      expect(output).to include('columns-2')
      expect(output).to include('break-after-column')
      expect(output).to include('Section 1')
      expect(output).to include('Section 2')
    end
  end
end