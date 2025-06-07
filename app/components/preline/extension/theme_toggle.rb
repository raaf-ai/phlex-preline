# frozen_string_literal: true

module Components
  module Preline
    module Extension
      # Theme toggle component that provides a dropdown interface for switching between light, dark, and system themes.
      # Integrates with the Stimulus theme-toggle controller to persist theme preferences and handle system theme detection.
      #
      # @example Basic usage
      #   ThemeToggle()
      #
      # @example Small theme toggle positioned on the left
      #   ThemeToggle(size: :sm, position: :left)
      #
      # @example Large theme toggle in a navbar
      #   Navbar do
      #     NavbarBrand(text: "My App")
      #     NavbarNav do
      #       ThemeToggle(size: :lg)
      #     end
      #   end
      #
      # @example In a user profile dropdown
      #   Dropdown(trigger_text: "Profile") do
      #     DropdownItem(text: "Settings", href: "/settings")
      #     DropdownDivider()
      #     ThemeToggle(size: :sm)
      #   end
      #
      # @param size [Symbol] Size variant (:sm, :md, :lg) - affects button and icon sizes
      # @param position [Symbol] Dropdown position (:left, :right) - determines where the dropdown appears
      class ThemeToggle < Components::Preline::PrelineComponent
        def initialize(size: :md, position: :right)
          @size = size
          @position = position
        end

        def view_template
          div(
            class: 'hs-dropdown relative inline-flex',
            data: { controller: 'theme-toggle' }
          ) do
            button(
              id: 'theme-dropdown-toggle',
              type: 'button',
              class: theme_toggle_classes,
              data: {
                action: 'click->theme-toggle#toggleDropdown',
                'hs-dropdown-toggle': ''
              },
              aria: { expanded: false, label: 'Theme selector' }
            ) do
              # Theme icon (will be updated by JavaScript)
              svg(
                id: 'theme-icon',
                class: icon_classes,
                fill: 'none',
                stroke: 'currentColor',
                viewBox: '0 0 24 24'
              ) do |s|
                # Default to sun icon (light theme)
                s.path(
                  stroke_linecap: 'round',
                  stroke_linejoin: 'round',
                  stroke_width: '2',
                  d: 'M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z'
                )
              end

              # Dropdown chevron
              svg(
                class: 'ml-1 h-3 w-3 theme-text-tertiary',
                fill: 'none',
                stroke: 'currentColor',
                viewBox: '0 0 24 24'
              ) do |s|
                s.path(
                  stroke_linecap: 'round',
                  stroke_linejoin: 'round',
                  stroke_width: '2',
                  d: 'M19 9l-7 7-7-7'
                )
              end
            end

            # Dropdown menu
            div(
              id: 'theme-dropdown-menu',
              class: dropdown_menu_classes,
              data: { 'hs-dropdown-menu': '' },
              aria: { labelledby: 'theme-dropdown-toggle' }
            ) do
              div(class: 'py-1') do
                # Light theme option
                button(
                  type: 'button',
                  class: dropdown_item_classes,
                  data: {
                    action: 'click->theme-toggle#setTheme',
                    theme: 'light'
                  }
                ) do
                  svg(
                    class: 'mr-3 h-4 w-4',
                    fill: 'none',
                    stroke: 'currentColor',
                    viewBox: '0 0 24 24'
                  ) do |s|
                    s.path(
                      stroke_linecap: 'round',
                      stroke_linejoin: 'round',
                      stroke_width: '2',
                      d: 'M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z'
                    )
                  end
                  span { I18n.t('preline.theme_toggle.light') }
                end

                # Dark theme option
                button(
                  type: 'button',
                  class: dropdown_item_classes,
                  data: {
                    action: 'click->theme-toggle#setTheme',
                    theme: 'dark'
                  }
                ) do
                  svg(
                    class: 'mr-3 h-4 w-4',
                    fill: 'none',
                    stroke: 'currentColor',
                    viewBox: '0 0 24 24'
                  ) do |s|
                    s.path(
                      stroke_linecap: 'round',
                      stroke_linejoin: 'round',
                      stroke_width: '2',
                      d: 'M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z'
                    )
                  end
                  span { I18n.t('preline.theme_toggle.dark') }
                end

                # System theme option
                button(
                  type: 'button',
                  class: dropdown_item_classes,
                  data: {
                    action: 'click->theme-toggle#setTheme',
                    theme: 'system'
                  }
                ) do
                  svg(
                    class: 'mr-3 h-4 w-4',
                    fill: 'none',
                    stroke: 'currentColor',
                    viewBox: '0 0 24 24'
                  ) do |s|
                    s.path(
                      stroke_linecap: 'round',
                      stroke_linejoin: 'round',
                      stroke_width: '2',
                      d: 'M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z'
                    )
                  end
                  span { I18n.t('preline.theme_toggle.system') }
                end
              end
            end
          end
        end

        private

        attr_reader :size, :position

        def theme_toggle_classes
          base_classes = %w[
            hs-dropdown-toggle
            inline-flex
            items-center
            justify-center
            rounded-md
            border
            font-medium
            focus:outline-none
            focus:ring-2
            focus:ring-offset-2
            focus:ring-blue-500
            theme-button-secondary
            transition-colors
            duration-200
          ]

          size_classes = case size
                         when :sm then %w[px-2 py-1 text-sm]
                         when :lg then %w[px-4 py-3 text-base]
                         else %w[px-3 py-2 text-sm]
                         end

          (base_classes + size_classes).join(' ')
        end

        def icon_classes
          case size
          when :sm then 'h-3 w-3'
          when :lg then 'h-6 w-6'
          else 'h-4 w-4'
          end
        end

        def dropdown_menu_classes
          position_classes = case position
                             when :left then 'left-0'
                             else 'right-0'
                             end

          [
            'hs-dropdown-menu',
            'hidden',
            'absolute',
            position_classes,
            'mt-2',
            'w-48',
            'rounded-md',
            'shadow-lg',
            'ring-1',
            'ring-black/5',
            'z-50',
            'theme-card'
          ].join(' ')
        end

        def dropdown_item_classes
          %w[
            flex
            w-full
            items-center
            px-4
            py-2
            text-sm
            theme-text-primary
            hover:theme-bg-secondary
            focus:outline-none
            focus:theme-bg-secondary
            transition-colors
            duration-150
          ].join(' ')
        end
      end
    end
  end
end
