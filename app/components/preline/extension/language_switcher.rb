# frozen_string_literal: true

module Components
  module Preline
    module Extension
      # Language switcher component that provides a dropdown interface for changing the application locale.
      # Uses Rails' I18n system and supports 6 languages: English, Dutch, German, French, Spanish, and Portuguese.
      #
      # @example Basic usage
      #   LanguageSwitcher()
      #
      # @example With specific current locale
      #   LanguageSwitcher(current_locale: :de)
      #
      # @example In a navbar
      #   Navbar do
      #     NavbarBrand(text: "My App")
      #     NavbarNav do
      #       LanguageSwitcher()
      #     end
      #   end
      #
      # @param current_locale [String, Symbol] The currently active locale (defaults to I18n.locale)
      class LanguageSwitcher < Components::Preline::PrelineComponent
        def initialize(current_locale: I18n.locale)
          @current_locale = current_locale.to_s
        end

        private

        attr_reader :current_locale

        def view_template
          dropdown_items = language_options.map do |locale, name|
            if locale == current_locale
              {
                text: name,
                icon: flag_icon_for(locale).split.last,
                active: true,
                href: '#'
              }
            else
              {
                text: name,
                icon: flag_icon_for(locale).split.last,
                href: set_locale_path(locale: locale),
                data: { method: :post }
              }
            end
          end

          Dropdown(
            trigger_text: current_language_name,
            trigger_icon: 'globe',
            items: dropdown_items,
            trigger_variant: :outline,
            placement: :'bottom-end',
            class: 'language-switcher'
          )
        end

        def current_language_name
          language_options[current_locale] || language_options['en']
        end

        def language_options
          {
            'en' => t('preline.language_switcher.english'),
            'nl' => t('preline.language_switcher.dutch'),
            'de' => t('preline.language_switcher.german'),
            'fr' => t('preline.language_switcher.french'),
            'es' => t('preline.language_switcher.spanish'),
            'pt' => t('preline.language_switcher.portuguese')
          }
        end

        def flag_icon_for(_locale)
          'fas fa-flag'
        end
      end
    end
  end
end
