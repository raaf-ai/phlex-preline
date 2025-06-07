# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Preline::SearchBox, type: :component do
  describe '#view_template' do
    it 'renders basic search box' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('hs-search-box')
      expect(output).to include('type="search"')
      expect(output).to include('name="search"')
    end

    it 'renders with custom name' do
      component = described_class.new(name: "product_search")
      output = render_phlex(component)
      
      expect(output).to include('name="product_search"')
    end

    it 'uses default name when not provided' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('name="search"')
    end

    it 'renders with custom placeholder' do
      component = described_class.new(placeholder: "Search products...")
      output = render_phlex(component)
      
      expect(output).to include('placeholder="Search products..."')
    end

    it 'uses default placeholder when not provided' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('placeholder="Search..."')
    end

    it 'renders with value' do
      component = described_class.new(value: "iPhone")
      output = render_phlex(component)
      
      expect(output).to include('value="iPhone"')
    end

    it 'renders with custom ID' do
      component = described_class.new(id: "custom-search")
      output = render_phlex(component)
      
      expect(output).to include('id="custom-search"')
    end

    it 'generates unique ID when not provided' do
      component1 = described_class.new
      component2 = described_class.new
      output1 = render_phlex(component1)
      output2 = render_phlex(component2)
      
      id1 = output1.match(/id="([^"]+)"/)[1]
      id2 = output2.match(/id="([^"]+)"/)[1]
      
      expect(id1).to start_with('search_box_')
      expect(id2).to start_with('search_box_')
      expect(id1).not_to eq(id2)
    end

    it 'renders with different sizes' do
      [:sm, :default, :lg].each do |size|
        component = described_class.new(size: size)
        output = render_phlex(component)
        
        expect(output).to include('hs-search-box')
      end
    end

    it 'renders with dropdown enabled' do
      component = described_class.new(dropdown: true)
      output = render_phlex(component)
      
      expect(output).to include('hs-search-box-dropdown')
    end

    it 'does not render dropdown when disabled' do
      component = described_class.new(dropdown: false)
      output = render_phlex(component)
      
      expect(output).not_to include('hs-search-box-dropdown')
    end

    it 'renders with suggestions' do
      suggestions = [
        { text: "iPhone 15", href: "/products/1", icon: "mobile" },
        { text: "MacBook Pro", href: "/products/2", icon: "laptop" }
      ]
      component = described_class.new(suggestions: suggestions)
      output = render_phlex(component)
      
      expect(output).to include('iPhone 15')
      expect(output).to include('MacBook Pro')
      expect(output).to include('/products/1')
      expect(output).to include('/products/2')
    end

    it 'renders suggestions with metadata' do
      suggestions = [
        { text: "John Doe", href: "/users/1", meta: "Customer" },
        { text: "Jane Smith", href: "/users/2", meta: "Admin" }
      ]
      component = described_class.new(suggestions: suggestions)
      output = render_phlex(component)
      
      expect(output).to include('John Doe')
      expect(output).to include('Customer')
      expect(output).to include('Jane Smith')
      expect(output).to include('Admin')
    end

    it 'renders with clear button enabled' do
      component = described_class.new(clear_button: true)
      output = render_phlex(component)
      
      expect(output).to include('hs-search-box-clear')
    end

    it 'does not render clear button when disabled' do
      component = described_class.new(clear_button: false)
      output = render_phlex(component)
      
      expect(output).not_to include('hs-search-box-clear')
    end

    it 'renders with search button enabled' do
      component = described_class.new(search_button: true)
      output = render_phlex(component)
      
      expect(output).to include('type="submit"')
      expect(output).to include('Search')
    end

    it 'does not render search button when disabled' do
      component = described_class.new(search_button: false)
      output = render_phlex(component)
      
      expect(output).not_to include('type="submit"')
    end

    it 'renders disabled search box' do
      component = described_class.new(disabled: true)
      output = render_phlex(component)
      
      expect(output).to include('disabled')
    end

    it 'does not render disabled when false' do
      component = described_class.new(disabled: false)
      output = render_phlex(component)
      
      expect(output).not_to include('disabled="')
      expect(output).not_to include('disabled>')
    end

    it 'renders with custom CSS classes' do
      component = described_class.new(class: "custom-search")
      output = render_phlex(component)
      
      expect(output).to include('custom-search')
    end

    it 'renders with data attributes' do
      component = described_class.new(
        data: { controller: "search-controller", testid: "search-test" }
      )
      output = render_phlex(component)
      
      expect(output).to include('data-controller="search-controller"')
      expect(output).to include('data-testid="search-test"')
    end

    it 'renders with aria attributes' do
      component = described_class.new(
        aria: { label: "Global search", describedby: "search-help" }
      )
      output = render_phlex(component)
      
      expect(output).to include('aria-label="Global search"')
      expect(output).to include('aria-describedby="search-help"')
    end

    it 'includes search icon' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('svg')
      expect(output).to include('search')
    end

    it 'includes Preline data attributes' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('data-hs-search-box')
    end

    it 'renders with all features combined' do
      suggestions = [{ text: "Test", href: "/test" }]
      component = described_class.new(
        name: "global_search",
        placeholder: "Search everything...",
        value: "customer",
        size: :lg,
        dropdown: true,
        suggestions: suggestions,
        clear_button: true,
        search_button: true
      )
      output = render_phlex(component)
      
      expect(output).to include('name="global_search"')
      expect(output).to include('placeholder="Search everything..."')
      expect(output).to include('value="customer"')
      expect(output).to include('hs-search-box-dropdown')
      expect(output).to include('Test')
      expect(output).to include('hs-search-box-clear')
      expect(output).to include('type="submit"')
    end
  end

  describe 'edge cases' do
    it 'handles empty suggestions array' do
      component = described_class.new(suggestions: [])
      output = render_phlex(component)
      
      expect(output).to include('hs-search-box')
    end

    it 'handles nil suggestions' do
      component = described_class.new(suggestions: nil)
      
      expect { render_phlex(component) }.not_to raise_error
    end

    it 'handles suggestions without href' do
      suggestions = [{ text: "No link item" }]
      component = described_class.new(suggestions: suggestions)
      output = render_phlex(component)
      
      expect(output).to include('No link item')
    end

    it 'handles suggestions without text' do
      suggestions = [{ href: "/test" }]
      component = described_class.new(suggestions: suggestions)
      
      expect { render_phlex(component) }.not_to raise_error
    end

    it 'handles empty placeholder' do
      component = described_class.new(placeholder: "")
      output = render_phlex(component)
      
      expect(output).to include('placeholder=""')
    end

    it 'handles nil value' do
      component = described_class.new(value: nil)
      output = render_phlex(component)
      
      expect(output).not_to include('value=')
    end

    it 'handles empty value' do
      component = described_class.new(value: "")
      output = render_phlex(component)
      
      expect(output).to include('value=""')
    end

    it 'handles invalid size gracefully' do
      component = described_class.new(size: :invalid)
      
      expect { render_phlex(component) }.not_to raise_error
    end

    it 'handles boolean attributes correctly' do
      component = described_class.new(
        dropdown: false,
        clear_button: false,
        search_button: false,
        disabled: false
      )
      output = render_phlex(component)
      
      expect(output).not_to include('hs-search-box-dropdown')
      expect(output).not_to include('hs-search-box-clear')
      expect(output).not_to include('type="submit"')
      expect(output).not_to include('disabled')
    end
  end

  describe 'validation' do
    it 'does not require any parameters' do
      expect { described_class.new }.not_to raise_error
    end

    it 'accepts valid size values' do
      [:sm, :default, :lg].each do |size|
        expect { described_class.new(size: size) }.not_to raise_error
      end
    end

    it 'accepts boolean parameters' do
      [true, false, nil].each do |bool_value|
        expect do
          described_class.new(
            dropdown: bool_value,
            clear_button: bool_value,
            search_button: bool_value,
            disabled: bool_value
          )
        end.not_to raise_error
      end
    end

    it 'accepts array of suggestions' do
      suggestions = [
        { text: "Item 1", href: "/1" },
        { text: "Item 2", href: "/2", icon: "star", meta: "Popular" }
      ]
      expect { described_class.new(suggestions: suggestions) }.not_to raise_error
    end
  end
  
  describe 'initialization' do
    it 'accepts valid parameters' do
      expect { described_class.new }.not_to raise_error
    end

    it 'accepts all optional parameters' do
      expect do
        described_class.new(
          name: "test_search",
          id: "custom-id",
          placeholder: "Custom placeholder",
          value: "test value",
          size: :lg,
          dropdown: true,
          suggestions: [{ text: "Test", href: "/test" }],
          clear_button: false,
          search_button: false,
          disabled: true,
          class: "custom-class",
          data: { test: "value" },
          aria: { label: "Test" }
        )
      end.not_to raise_error
    end

    it 'sets default values correctly' do
      component = described_class.new
      output = render_phlex(component)
      
      expect(output).to include('name="search"')
      expect(output).to include('placeholder="Search..."')
      expect(output).to include('hs-search-box-clear')
      expect(output).to include('type="submit"')
    end
  end
end
