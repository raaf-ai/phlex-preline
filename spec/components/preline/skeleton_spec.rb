# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::Skeleton, type: :component do
  describe '#view_template' do
    it 'renders basic text skeleton' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('<div')
      expect(output).to include('class="hs-skeleton hs-skeleton-text hs-skeleton-animated"')
      expect(output).to have_executed_code_path('Renders skeleton component')
      expect(output).to have_executed_code_path('Renders basic skeleton')
      expect(output).to have_executed_code_path('Adds animation')
    end

    it 'renders skeleton without animation' do
      component = described_class.new(animated: false)
      output = render_phlex(component)
      
      expect(output).to include('hs-skeleton')
      expect(output).to include('hs-skeleton-text')
      expect(output).not_to include('hs-skeleton-animated')
    end

    it 'renders skeleton with rounded corners' do
      component = described_class.new(rounded: true)
      output = render_phlex(component)
      
      expect(output).to include('hs-skeleton-rounded')
      expect(output).to have_executed_code_path('Adds rounded corners')
    end

    it 'renders skeleton with custom width' do
      component = described_class.new(width: '200px')
      output = render_phlex(component)
      
      expect(output).to include('style="width: 200px;"')
      expect(output).to have_executed_code_path('Adds custom width')
    end

    it 'renders skeleton with custom height' do
      component = described_class.new(height: '50px')
      output = render_phlex(component)
      
      expect(output).to include('style="height: 50px;"')
      expect(output).to have_executed_code_path('Adds custom height')
    end

    it 'renders skeleton with both width and height' do
      component = described_class.new(width: '300px', height: '100px')
      output = render_phlex(component)
      
      expect(output).to include('style="width: 300px; height: 100px;"')
    end
  end

  describe 'skeleton types' do
    it 'renders title skeleton' do
      component = described_class.new(type: :title)
      output = render_phlex(component)
      
      expect(output).to include('hs-skeleton-title')
    end

    it 'renders button skeleton' do
      component = described_class.new(type: :button)
      output = render_phlex(component)
      
      expect(output).to include('hs-skeleton-button')
    end

    it 'renders image skeleton' do
      component = described_class.new(type: :image)
      output = render_phlex(component)
      
      expect(output).to include('hs-skeleton-image')
    end
  end

  describe 'paragraph skeleton' do
    it 'renders single line paragraph' do
      component = described_class.new(type: :paragraph)
      output = render_phlex(component)
      
      expect(output).to include('hs-skeleton-paragraph')
      expect(output).to include('width: 80%;')
      expect(output).to have_executed_code_path('Renders paragraph skeleton')
      expect(output).to have_executed_code_path('Renders last paragraph line')
    end

    it 'renders multi-line paragraph' do
      component = described_class.new(type: :paragraph, lines: 3)
      output = render_phlex(component)
      
      # Count occurrences of skeleton-text
      text_count = output.scan('hs-skeleton-text').length
      expect(text_count).to eq(3)
      
      # Last line should be shorter
      expect(output).to include('width: 80%;')
      expect(output).to have_executed_code_path('Renders paragraph line')
      expect(output).to have_executed_code_path('Renders last paragraph line')
    end

    it 'renders paragraph without animation' do
      component = described_class.new(type: :paragraph, lines: 2, animated: false)
      output = render_phlex(component)
      
      expect(output).not_to include('hs-skeleton-animated')
    end
  end

  describe 'card skeleton' do
    it 'renders complete card skeleton' do
      component = described_class.new(type: :card)
      output = render_phlex(component)
      
      expect(output).to include('hs-skeleton-card')
      expect(output).to include('hs-skeleton-image')
      expect(output).to include('height: 200px;')
      expect(output).to include('hs-skeleton-card-body')
      expect(output).to include('hs-skeleton-title')
      expect(output).to include('width: 60%;')
      expect(output).to include('hs-skeleton-text')
      expect(output).to include('hs-skeleton-button')
      expect(output).to include('width: 100px;')
      expect(output).to have_executed_code_path('Renders card skeleton')
    end

    it 'renders card with custom class' do
      component = described_class.new(type: :card, class: 'my-card')
      output = render_phlex(component)
      
      expect(output).to include('hs-skeleton-card')
      expect(output).to include('my-card')
    end
  end

  describe 'avatar skeleton' do
    it 'renders basic avatar skeleton' do
      component = described_class.new(type: :avatar)
      output = render_phlex(component)
      
      expect(output).to include('hs-skeleton-avatar')
      expect(output).to include('width: 40px; height: 40px;')
      expect(output).to have_executed_code_path('Renders avatar skeleton')
      expect(output).to have_executed_code_path('Adds avatar animation')
    end

    it 'renders rounded avatar' do
      component = described_class.new(type: :avatar, rounded: true)
      output = render_phlex(component)
      
      expect(output).to include('hs-skeleton-rounded')
      expect(output).to have_executed_code_path('Adds rounded avatar')
    end

    it 'renders avatar with custom size via width' do
      component = described_class.new(type: :avatar, width: '60px')
      output = render_phlex(component)
      
      expect(output).to include('width: 60px; height: 60px;')
    end

    it 'renders avatar with custom size via height' do
      component = described_class.new(type: :avatar, height: '80px')
      output = render_phlex(component)
      
      expect(output).to include('width: 80px; height: 80px;')
    end

    it 'renders avatar without animation' do
      component = described_class.new(type: :avatar, animated: false)
      output = render_phlex(component)
      
      expect(output).not_to include('hs-skeleton-animated')
    end
  end

  describe 'HTML attributes' do
    it 'accepts custom classes' do
      component = described_class.new(class: 'my-skeleton')
      output = render_phlex(component)
      
      expect(output).to include('my-skeleton')
    end

    it 'accepts HTML attributes' do
      component = described_class.new(
        id: 'loading-skeleton',
        data: { test: 'value' },
        aria: { hidden: 'true' }
      )
      output = render_phlex(component)
      
      expect(output).to include('id="loading-skeleton"')
      expect(output).to include('data-test="value"')
      expect(output).to include('aria-hidden="true"')
    end

    it 'passes through additional attributes' do
      component = described_class.new(
        role: 'status',
        style: 'margin: 10px;'
      )
      output = render_phlex(component)
      
      expect(output).to include('role="status"')
      # Should merge with skeleton styles
      expect(output).to include('margin: 10px;')
    end
  end

  describe 'loading states example' do
    it 'renders article loading skeleton' do
      output = ''
      
      # Title skeleton
      title = described_class.new(type: :title, width: '70%')
      output += render_phlex(title)
      
      # Author avatar and name
      avatar = described_class.new(type: :avatar, rounded: true, width: '32px')
      output += render_phlex(avatar)
      
      # Content paragraph
      content = described_class.new(type: :paragraph, lines: 5)
      output += render_phlex(content)
      
      expect(output).to include('hs-skeleton-title')
      expect(output).to include('hs-skeleton-avatar')
      expect(output).to include('hs-skeleton-paragraph')
    end
  end
end