# frozen_string_literal: true

require 'uri'

module Components
  module Preline
    # A Preline UI pagination component for navigating through pages.
    # Supports customizable page windows, navigation controls, and item counts.
    #
    # @example Basic pagination
    #   render Components::Preline::Pagination.new(
    #     current_page: 3,
    #     total_pages: 10,
    #     path: "/products"
    #   )
    #
    # @example Pagination with item info
    #   render Components::Preline::Pagination.new(
    #     current_page: 2,
    #     total_pages: 5,
    #     total_items: 47,
    #     per_page: 10,
    #     show_info: true,
    #     path: "/users",
    #     params: { filter: "active" }
    #   )
    #
    # @example Compact pagination
    #   render Components::Preline::Pagination.new(
    #     current_page: @page,
    #     total_pages: @total_pages,
    #     size: :sm,
    #     window: 1,
    #     show_first_last: false,
    #     path: request.path
    #   )
    class Pagination < ::Components::Preline::PrelineComponent
      # Initialize a new Pagination component
      #
      # @param current_page [Integer] Current page number (1-based)
      # @param total_pages [Integer] Total number of pages
      # @param per_page [Integer] Items per page (for info display)
      # @param total_items [Integer, nil] Total number of items (for info display)
      # @param window [Integer] Number of pages to show around current page
      # @param outer_window [Integer] Number of pages to show at start/end
      # @param path [String, nil] Base path for page links
      # @param params [Hash] Additional URL parameters to preserve
      # @param size [Symbol] Size variant (:sm, :md, :lg)
      # @param show_info [Boolean] Show "Showing X-Y of Z results" text
      # @param show_first_last [Boolean] Show first/last page buttons
      # @param show_prev_next [Boolean] Show previous/next buttons
      # @param class [String] Additional CSS classes
      def initialize(
        current_page:,
        total_pages:,
        per_page: 10,
        total_items: nil,
        window: 2,
        outer_window: 1,
        path: nil,
        params: {},
        size: :md,
        show_info: false,
        show_first_last: true,
        show_prev_next: true,
        **attrs
      )
        @current_page = current_page.to_i
        @total_pages = total_pages.to_i
        @per_page = per_page
        @total_items = total_items
        @window = window
        @outer_window = outer_window
        @path = path
        @params = params
        @size = size
        @show_info = show_info
        @show_first_last = show_first_last
        @show_prev_next = show_prev_next
        @custom_class = attrs.delete(:class)
      end

      def view_template
        return if @total_pages <= 1

        code_path 'Renders pagination navigation with page controls'
        nav(aria: { label: 'Pagination Navigation' }) do
          render_pagination_info if @show_info && @total_items

          ul(class: build_classes) do
            render_first_page if @show_first_last && @current_page > 1
            render_previous_page if @show_prev_next
            render_page_numbers
            render_next_page if @show_prev_next
            render_last_page if @show_first_last && @current_page < @total_pages
          end
        end
      end

      private

      def build_classes
        classes = ['hs-pagination']
        classes << "hs-pagination-#{@size}" if @size != :md
        classes << @custom_class
        classes.join(' ').strip
      end

      def render_pagination_info
        code_path 'Renders pagination info showing item count and range'
        div(class: 'hs-pagination-info') do
          start_item = ((@current_page - 1) * @per_page) + 1
          end_item = [@current_page * @per_page, @total_items].min

          span do
            plain "#{I18n.t('preline.pagination.showing', default: 'Showing')} "
            strong { "#{start_item}-#{end_item}" }
            plain " #{I18n.t('preline.pagination.of', default: 'of')} "
            strong { @total_items.to_s }
            plain " #{I18n.t('preline.pagination.results', default: 'results')}"
          end
        end
      end

      def render_first_page
        code_path 'Renders first page navigation button with double arrow'
        li(class: 'hs-pagination-item') do
          a(
            href: page_url(1),
            class: 'hs-pagination-link hs-pagination-compact',
            data: { turbo: 'false' },
            aria: { label: I18n.t('preline.pagination.first_page', default: 'First page') }
          ) do
            render double_chevron_left_icon
            span(class: 'hs-pagination-text') { I18n.t('preline.pagination.first', default: 'First') }
          end
        end
      end

      def render_previous_page
        code_path 'Renders previous page navigation button'
        li(class: "hs-pagination-item #{'hs-pagination-disabled' if @current_page <= 1}") do
          if @current_page > 1
            code_path 'Renders clickable previous button with page link'
            a(
              href: page_url(@current_page - 1),
              class: 'hs-pagination-link',
              data: { turbo: 'false' },
              aria: { label: I18n.t('preline.pagination.previous_page', default: 'Previous page') }
            ) do
              render chevron_left_icon
              span(class: 'hs-pagination-text') { I18n.t('preline.pagination.previous', default: 'Previous') }
            end
          else
            code_path 'Renders disabled previous button at first page'
            span(class: 'hs-pagination-link hs-pagination-disabled') do
              render chevron_left_icon
              span(class: 'hs-pagination-text') { I18n.t('preline.pagination.previous', default: 'Previous') }
            end
          end
        end
      end

      def render_page_numbers
        code_path 'Renders numbered page links with current page highlighted'
        page_numbers.each do |page|
          if page == :gap
            render_gap
          else
            render_page_link(page)
          end
        end
      end

      def render_page_link(page)
        is_current = page == @current_page
        code_path 'Renders current page number with active styling' if is_current
        code_path 'Renders clickable page number link' unless is_current

        li(class: "hs-pagination-item #{'hs-pagination-active' if is_current}") do
          if is_current
            span(
              class: 'hs-pagination-link hs-pagination-current',
              aria: { current: 'page' }
            ) { page.to_s }
          else
            a(
              href: page_url(page),
              class: 'hs-pagination-link',
              data: { turbo: 'false' }
            ) { page.to_s }
          end
        end
      end

      def render_gap
        code_path 'Renders ellipsis indicator for skipped page numbers'
        li(class: 'hs-pagination-item hs-pagination-gap') do
          span(class: 'hs-pagination-ellipsis') { I18n.t('preline.pagination.ellipsis', default: '...') }
        end
      end

      def render_next_page
        code_path 'Renders next page navigation button'
        li(class: "hs-pagination-item #{'hs-pagination-disabled' if @current_page >= @total_pages}") do
          if @current_page < @total_pages
            code_path 'Renders clickable next button with page link'
            a(
              href: page_url(@current_page + 1),
              class: 'hs-pagination-link',
              data: { turbo: 'false' },
              aria: { label: I18n.t('preline.pagination.next_page', default: 'Next page') }
            ) do
              span(class: 'hs-pagination-text') { I18n.t('preline.pagination.next', default: 'Next') }
              render chevron_right_icon
            end
          else
            code_path 'Renders disabled next button at last page'
            span(class: 'hs-pagination-link hs-pagination-disabled') do
              span(class: 'hs-pagination-text') { I18n.t('preline.pagination.next', default: 'Next') }
              render chevron_right_icon
            end
          end
        end
      end

      def render_last_page
        code_path 'Renders last page navigation button with double arrow'
        li(class: 'hs-pagination-item') do
          a(
            href: page_url(@total_pages),
            class: 'hs-pagination-link hs-pagination-compact',
            data: { turbo: 'false' },
            aria: { label: I18n.t('preline.pagination.last_page', default: 'Last page') }
          ) do
            span(class: 'hs-pagination-text') { I18n.t('preline.pagination.last', default: 'Last') }
            render double_chevron_right_icon
          end
        end
      end

      def page_numbers
        return [] if @total_pages.zero?

        left_window = [@current_page - @window, 1].max
        right_window = [@current_page + @window, @total_pages].min

        # Add pages at the start
        numbers = (1..[@outer_window, @total_pages].min).to_a

        # Add gap if needed
        numbers << :gap if @outer_window + 1 < left_window

        # Add pages around current
        (left_window..right_window).each { |i| numbers << i unless numbers.include?(i) }

        # Add gap if needed
        numbers << :gap if right_window < @total_pages - @outer_window

        # Add pages at the end
        ([@total_pages - @outer_window + 1, 1].max..@total_pages).each { |i| numbers << i unless numbers.include?(i) }

        numbers
      end

      def page_url(page)
        return '#' unless @path

        query_params = @params.merge(page: page)
        query_string = URI.encode_www_form(query_params)
        query_string.empty? ? @path : "#{@path}?#{query_string}"
      end

      # SVG icon helper methods
      def double_chevron_left_icon
        svg(class: "w-4 h-4", fill: "currentColor", viewBox: "0 0 20 20", xmlns: "http://www.w3.org/2000/svg") do |s|
          s.path(fill_rule: "evenodd", d: "M15.707 15.707a1 1 0 01-1.414 0l-5-5a1 1 0 010-1.414l5-5a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 010 1.414zm-6 0a1 1 0 01-1.414 0l-5-5a1 1 0 010-1.414l5-5a1 1 0 111.414 1.414L5.414 10l4.293 4.293a1 1 0 010 1.414z", clip_rule: "evenodd", transform: "rotate(180 10 10)")
        end
      end

      def chevron_left_icon
        svg(class: "w-4 h-4", fill: "currentColor", viewBox: "0 0 20 20", xmlns: "http://www.w3.org/2000/svg") do |s|
          s.path(fill_rule: "evenodd", d: "M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z", clip_rule: "evenodd")
        end
      end

      def chevron_right_icon
        svg(class: "w-4 h-4", fill: "currentColor", viewBox: "0 0 20 20", xmlns: "http://www.w3.org/2000/svg") do |s|
          s.path(fill_rule: "evenodd", d: "M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z", clip_rule: "evenodd")
        end
      end

      def double_chevron_right_icon
        svg(class: "w-4 h-4", fill: "currentColor", viewBox: "0 0 20 20", xmlns: "http://www.w3.org/2000/svg") do |s|
          s.path(fill_rule: "evenodd", d: "M10.293 15.707a1 1 0 010-1.414L14.586 10l-4.293-4.293a1 1 0 111.414-1.414l5 5a1 1 0 010 1.414l-5 5a1 1 0 01-1.414 0zm-6 0a1 1 0 010-1.414L8.586 10 4.293 5.707a1 1 0 011.414-1.414l5 5a1 1 0 010 1.414l-5 5a1 1 0 01-1.414 0z", clip_rule: "evenodd")
        end
      end
    end
  end
end
