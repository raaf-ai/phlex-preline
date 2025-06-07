# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Typography, type: :component do
  describe '#view_template' do
    it 'renders basic paragraph by default' do
      component = described_class.new
      output = render_phlex(component) do
        "This is a paragraph"
      end
      
      expect(output).to include('<p')
      expect(output).to include('class="hs-typography"')
      expect(output).to include('This is a paragraph')
      expect(output).to have_executed_code_path('Renders typography component')
      expect(output).to have_executed_code_path('Renders typography with content')
    end

    it 'renders empty typography' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('<p')
      expect(output).to have_executed_code_path('Renders empty typography')
    end

    it 'renders heading with tag option' do
      component = described_class.new(tag: :h1)
      output = render_phlex(component) do
        "Main Heading"
      end
      
      expect(output).to include('<h1')
      expect(output).to include('Main Heading')
    end

    it 'renders with size' do
      component = described_class.new(size: :xl)
      output = render_phlex(component) do
        "Large text"
      end
      
      expect(output).to include('text-xl')
      expect(output).to have_executed_code_path('Adds text size')
    end

    it 'renders with font weight' do
      component = described_class.new(weight: :bold)
      output = render_phlex(component) do
        "Bold text"
      end
      
      expect(output).to include('font-bold')
      expect(output).to have_executed_code_path('Adds font weight')
    end

    it 'renders with color' do
      component = described_class.new(color: :primary)
      output = render_phlex(component) do
        "Primary color text"
      end
      
      expect(output).to include('theme-accent-primary')
      expect(output).to have_executed_code_path('Adds text color')
    end

    it 'renders with text alignment' do
      component = described_class.new(align: :center)
      output = render_phlex(component) do
        "Centered text"
      end
      
      expect(output).to include('text-center')
      expect(output).to have_executed_code_path('Adds text alignment')
    end

    it 'renders with text transform' do
      component = described_class.new(transform: :uppercase)
      output = render_phlex(component) do
        "uppercase text"
      end
      
      expect(output).to include('uppercase')
      expect(output).to have_executed_code_path('Adds text transform')
    end

    it 'renders with text decoration' do
      component = described_class.new(decoration: :underline)
      output = render_phlex(component) do
        "Underlined text"
      end
      
      expect(output).to include('underline')
      expect(output).to have_executed_code_path('Adds text decoration')
    end

    it 'renders with line height' do
      component = described_class.new(leading: :relaxed)
      output = render_phlex(component) do
        "Text with relaxed line height"
      end
      
      expect(output).to include('leading-relaxed')
      expect(output).to have_executed_code_path('Adds line height')
    end

    it 'renders with letter spacing' do
      component = described_class.new(tracking: :wide)
      output = render_phlex(component) do
        "Wide letter spacing"
      end
      
      expect(output).to include('tracking-wide')
      expect(output).to have_executed_code_path('Adds letter spacing')
    end

    it 'renders with truncation' do
      component = described_class.new(truncate: true)
      output = render_phlex(component) do
        "This is a very long text that will be truncated"
      end
      
      expect(output).to include('truncate')
      expect(output).to have_executed_code_path('Adds text truncation')
    end

    it 'renders with multiple properties' do
      component = described_class.new(
        tag: :h2,
        size: :'2xl',
        weight: :semibold,
        color: :primary,
        align: :center,
        transform: :uppercase,
        tracking: :wide
      )
      output = render_phlex(component) do
        "Complex Heading"
      end
      
      expect(output).to include('<h2')
      expect(output).to include('text-2xl')
      expect(output).to include('font-semibold')
      expect(output).to include('theme-accent-primary')
      expect(output).to include('text-center')
      expect(output).to include('uppercase')
      expect(output).to include('tracking-wide')
    end

    it 'accepts custom classes' do
      component = described_class.new(
        class: 'my-custom-class hover:underline'
      )
      output = render_phlex(component) do
        "Custom styled text"
      end
      
      expect(output).to include('my-custom-class hover:underline')
    end

    it 'accepts HTML attributes' do
      component = described_class.new(
        id: 'main-title',
        data: { section: 'header' },
        aria: { level: '1' }
      )
      output = render_phlex(component) do
        "Title"
      end
      
      expect(output).to include('id="main-title"')
      expect(output).to include('data-section="header"')
      expect(output).to include('aria-level="1"')
    end
  end

  describe 'all tag types' do
    %i[h1 h2 h3 h4 h5 h6 p span div dt dd dl].each do |tag|
      it "renders #{tag} tag" do
        component = described_class.new(tag: tag)
        output = render_phlex(component) do
          "Content"
        end
        
        expect(output).to include("<#{tag}")
      end
    end
  end

  describe 'all size options' do
    %i[xs sm base lg xl 2xl 3xl 4xl 5xl 6xl].each do |size|
      it "renders #{size} size" do
        component = described_class.new(size: size)
        output = render_phlex(component) do
          "Text"
        end
        
        expect(output).to include("text-#{size}")
      end
    end
  end

  describe 'all weight options' do
    %i[thin extralight light normal medium semibold bold extrabold black].each do |weight|
      it "renders #{weight} weight" do
        component = described_class.new(weight: weight)
        output = render_phlex(component) do
          "Text"
        end
        
        expect(output).to include("font-#{weight}")
      end
    end
  end

  describe 'all color options' do
    {
      primary: 'theme-accent-primary',
      secondary: 'theme-text-secondary',
      success: 'theme-success',
      danger: 'theme-error',
      warning: 'theme-warning',
      info: 'theme-info',
      muted: 'theme-text-tertiary',
      dark: 'theme-text-primary',
      light: 'theme-text-tertiary'
    }.each do |color, class_name|
      it "renders #{color} color" do
        component = described_class.new(color: color)
        output = render_phlex(component) do
          "Text"
        end
        
        expect(output).to include(class_name)
      end
    end
  end

  describe 'text alignment' do
    %i[left center right justify].each do |align|
      it "renders #{align} alignment" do
        component = described_class.new(align: align)
        output = render_phlex(component) do
          "Text"
        end
        
        expect(output).to include("text-#{align}")
      end
    end
  end

  describe 'text transform' do
    {
      uppercase: 'uppercase',
      lowercase: 'lowercase',
      capitalize: 'capitalize',
      normal: 'normal-case'
    }.each do |transform, class_name|
      it "renders #{transform} transform" do
        component = described_class.new(transform: transform)
        output = render_phlex(component) do
          "Text"
        end
        
        expect(output).to include(class_name)
      end
    end
  end

  describe 'text decoration' do
    {
      underline: 'underline',
      overline: 'overline',
      line_through: 'line-through',
      none: 'no-underline'
    }.each do |decoration, class_name|
      it "renders #{decoration} decoration" do
        component = described_class.new(decoration: decoration)
        output = render_phlex(component) do
          "Text"
        end
        
        expect(output).to include(class_name)
      end
    end
  end

  describe 'line height' do
    %i[none tight snug normal relaxed loose].each do |leading|
      it "renders #{leading} line height" do
        component = described_class.new(leading: leading)
        output = render_phlex(component) do
          "Text"
        end
        
        expect(output).to include("leading-#{leading}")
      end
    end
  end

  describe 'letter spacing' do
    %i[tighter tight normal wide wider widest].each do |tracking|
      it "renders #{tracking} letter spacing" do
        component = described_class.new(tracking: tracking)
        output = render_phlex(component) do
          "Text"
        end
        
        expect(output).to include("tracking-#{tracking}")
      end
    end
  end

  describe 'validation' do
    it 'validates tag inclusion' do
      expect do
        described_class.new(tag: :invalid)
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end

    it 'validates size inclusion' do
      expect do
        described_class.new(size: :xxl)
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end

    it 'validates weight inclusion' do
      expect do
        described_class.new(weight: :super)
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end

    it 'validates color inclusion' do
      expect do
        described_class.new(color: :pink)
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end

    it 'validates align inclusion' do
      expect do
        described_class.new(align: :middle)
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end

    it 'validates transform inclusion' do
      expect do
        described_class.new(transform: :reverse)
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end

    it 'validates decoration inclusion' do
      expect do
        described_class.new(decoration: :bold)
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end

    it 'validates leading inclusion' do
      expect do
        described_class.new(leading: :double)
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end

    it 'validates tracking inclusion' do
      expect do
        described_class.new(tracking: :narrow)
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end

    it 'validates boolean truncate' do
      expect do
        described_class.new(truncate: 'yes')
      end.to raise_error(Phlex::Preline::InvalidParameterError)
    end
  end

  describe 'common use cases' do
    it 'renders page title' do
      component = described_class.new(
        tag: :h1,
        size: :'4xl',
        weight: :bold,
        color: :dark,
        class: 'mb-4'
      )
      output = render_phlex(component) do
        "Welcome to Our Platform"
      end
      
      expect(output).to include('<h1')
      expect(output).to include('text-4xl')
      expect(output).to include('font-bold')
      expect(output).to include('theme-text-primary')
      expect(output).to include('mb-4')
    end

    it 'renders muted subtitle' do
      component = described_class.new(
        tag: :p,
        size: :sm,
        color: :muted,
        class: 'mt-2'
      )
      output = render_phlex(component) do
        "Last updated 5 minutes ago"
      end
      
      expect(output).to include('<p')
      expect(output).to include('text-sm')
      expect(output).to include('theme-text-tertiary')
      expect(output).to include('mt-2')
    end

    it 'renders uppercase section header' do
      component = described_class.new(
        tag: :h3,
        size: :lg,
        weight: :semibold,
        transform: :uppercase,
        tracking: :wide,
        color: :primary
      )
      output = render_phlex(component) do
        "Featured Products"
      end
      
      expect(output).to include('<h3')
      expect(output).to include('text-lg')
      expect(output).to include('font-semibold')
      expect(output).to include('uppercase')
      expect(output).to include('tracking-wide')
      expect(output).to include('theme-accent-primary')
    end
  end
end