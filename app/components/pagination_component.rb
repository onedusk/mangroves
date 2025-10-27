# frozen_string_literal: true

class PaginationComponent < ApplicationComponent
  def initialize(
    current_page:,
    total_pages:,
    url_builder:,
    show_first_last: true,
    max_pages: 7,
    show_page_info: true
  )
    @current_page = current_page
    @total_pages = total_pages
    @url_builder = url_builder
    @show_first_last = show_first_last
    @max_pages = max_pages
    @show_page_info = show_page_info
  end

  def view_template
    return if @total_pages <= 1

    nav(
      role: "navigation",
      aria: {label: "Pagination"},
      data: {controller: "pagination"},
      class: "flex items-center justify-between px-4 py-3 bg-white border-t border-gray-200"
    ) do
      render_page_info if @show_page_info
      render_pagination_controls
    end
  end

  private

  def render_page_info
    div(class: "flex-1 flex justify-between sm:hidden") do
      render_prev_link(mobile: true)
      render_next_link(mobile: true)
    end

    div(class: "hidden sm:flex-1 sm:flex sm:items-center sm:justify-between") do
      div do
        p(class: "text-sm text-gray-700") do
          plain "Page "
          span(class: "font-medium") { @current_page }
          plain " of "
          span(class: "font-medium") { @total_pages }
        end
      end
      render_pagination_controls
    end
  end

  def render_pagination_controls
    div(class: "flex items-center gap-1") do
      render_first_link if @show_first_last && @current_page > 2
      render_prev_link
      render_page_numbers
      render_next_link
      render_last_link if @show_first_last && @current_page < @total_pages - 1
    end
  end

  def render_first_link
    a(
      href: @url_builder.call(1),
      rel: "first",
      data: {
        action: "click->pagination#navigate",
        pagination_target: "link"
      },
      aria: {label: "Go to first page"},
      class: control_button_classes
    ) do
      render_double_chevron_left_icon
      span(class: "sr-only") { "First" }
    end
  end

  def render_last_link
    a(
      href: @url_builder.call(@total_pages),
      rel: "last",
      data: {
        action: "click->pagination#navigate",
        pagination_target: "link"
      },
      aria: {label: "Go to last page"},
      class: control_button_classes
    ) do
      render_double_chevron_right_icon
      span(class: "sr-only") { "Last" }
    end
  end

  def render_prev_link(mobile: false)
    if @current_page > 1
      a(
        href: @url_builder.call(@current_page - 1),
        rel: "prev",
        data: {
          action: "click->pagination#navigate",
          pagination_target: "link"
        },
        aria: {label: "Go to previous page"},
        class: mobile ? mobile_button_classes : control_button_classes
      ) do
        render_chevron_left_icon
        span(class: mobile ? "" : "sr-only") { "Previous" }
      end
    else
      span(
        aria: {disabled: "true"},
        class: mobile ? disabled_mobile_button_classes : disabled_control_button_classes
      ) do
        render_chevron_left_icon
        span(class: mobile ? "" : "sr-only") { "Previous" }
      end
    end
  end

  def render_next_link(mobile: false)
    if @current_page < @total_pages
      a(
        href: @url_builder.call(@current_page + 1),
        rel: "next",
        data: {
          action: "click->pagination#navigate",
          pagination_target: "link"
        },
        aria: {label: "Go to next page"},
        class: mobile ? mobile_button_classes : control_button_classes
      ) do
        span(class: mobile ? "" : "sr-only") { "Next" }
        render_chevron_right_icon
      end
    else
      span(
        aria: {disabled: "true"},
        class: mobile ? disabled_mobile_button_classes : disabled_control_button_classes
      ) do
        span(class: mobile ? "" : "sr-only") { "Next" }
        render_chevron_right_icon
      end
    end
  end

  def render_page_numbers
    page_range.each do |page|
      if page == :gap
        span(class: "px-3 py-2 text-sm text-gray-500") { "..." }
      else
        render_page_number(page)
      end
    end
  end

  def render_page_number(page)
    is_current = page == @current_page

    if is_current
      span(
        aria: {label: "Current page", current: "page"},
        data: {pagination_target: "currentPage"},
        class: current_page_classes
      ) do
        page.to_s
      end
    else
      a(
        href: @url_builder.call(page),
        aria: {label: "Go to page #{page}"},
        data: {
          action: "click->pagination#navigate",
          pagination_target: "link"
        },
        class: page_number_classes
      ) do
        page.to_s
      end
    end
  end

  # Calculate which page numbers to show
  def page_range
    return (1..@total_pages).to_a if @total_pages <= @max_pages

    range = []
    left_offset = (@max_pages - 3) / 2
    right_offset = @max_pages - 3 - left_offset

    if @current_page <= left_offset + 2
      # Near start
      range = (1..(@max_pages - 2)).to_a
      range << :gap
      range << @total_pages
    elsif @current_page >= @total_pages - right_offset - 1
      # Near end
      range = [1, :gap]
      range.concat(((@total_pages - @max_pages + 3)..@total_pages).to_a)
    else
      # Middle
      range = [1, :gap]
      range.concat(((@current_page - left_offset)..(@current_page + right_offset)).to_a)
      range << :gap
      range << @total_pages
    end

    range
  end

  # Icon helpers
  def render_chevron_left_icon
    svg(
      class: "h-5 w-5",
      xmlns: "http://www.w3.org/2000/svg",
      viewBox: "0 0 20 20",
      fill: "currentColor",
      aria: {hidden: "true"}
    ) do |s|
      s.path(
        fill_rule: "evenodd",
        d: "M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 " \
           "01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z",
        clip_rule: "evenodd"
      )
    end
  end

  def render_chevron_right_icon
    svg(
      class: "h-5 w-5",
      xmlns: "http://www.w3.org/2000/svg",
      viewBox: "0 0 20 20",
      fill: "currentColor",
      aria: {hidden: "true"}
    ) do |s|
      s.path(
        fill_rule: "evenodd",
        d: "M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 " \
           "011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z",
        clip_rule: "evenodd"
      )
    end
  end

  def render_double_chevron_left_icon
    svg(
      class: "h-5 w-5",
      xmlns: "http://www.w3.org/2000/svg",
      viewBox: "0 0 20 20",
      fill: "currentColor",
      aria: {hidden: "true"}
    ) do |s|
      s.path(
        fill_rule: "evenodd",
        d: "M15.707 15.707a1 1 0 01-1.414 0l-5-5a1 1 0 010-1.414l5-5a1 1 0 " \
           "111.414 1.414L11.414 10l4.293 4.293a1 1 0 010 1.414zm-6 0a1 1 0 " \
           "01-1.414 0l-5-5a1 1 0 010-1.414l5-5a1 1 0 011.414 1.414L5.414 10l4.293 " \
           "4.293a1 1 0 010 1.414z",
        clip_rule: "evenodd"
      )
    end
  end

  def render_double_chevron_right_icon
    svg(
      class: "h-5 w-5",
      xmlns: "http://www.w3.org/2000/svg",
      viewBox: "0 0 20 20",
      fill: "currentColor",
      aria: {hidden: "true"}
    ) do |s|
      s.path(
        fill_rule: "evenodd",
        d: "M10.293 15.707a1 1 0 010-1.414L14.586 10l-4.293-4.293a1 1 0 " \
           "111.414-1.414l5 5a1 1 0 010 1.414l-5 5a1 1 0 01-1.414 0z",
        clip_rule: "evenodd"
      )
      s.path(
        fill_rule: "evenodd",
        d: "M4.293 15.707a1 1 0 010-1.414L8.586 10 4.293 5.707a1 1 0 " \
           "011.414-1.414l5 5a1 1 0 010 1.414l-5 5a1 1 0 01-1.414 0z",
        clip_rule: "evenodd"
      )
    end
  end

  # Style helpers
  def control_button_classes
    "inline-flex items-center px-3 py-2 text-sm font-medium text-gray-700 " \
      "bg-white border border-gray-300 rounded-lg hover:bg-gray-50 " \
      "focus:outline-none focus:ring-2 focus:ring-blue-500 transition-colors"
  end

  def disabled_control_button_classes
    "inline-flex items-center px-3 py-2 text-sm font-medium text-gray-400 " \
      "bg-gray-50 border border-gray-300 rounded-lg cursor-not-allowed"
  end

  def mobile_button_classes
    "inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-gray-700 " \
      "bg-white border border-gray-300 rounded-lg hover:bg-gray-50 " \
      "focus:outline-none focus:ring-2 focus:ring-blue-500 transition-colors"
  end

  def disabled_mobile_button_classes
    "inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-gray-400 " \
      "bg-gray-50 border border-gray-300 rounded-lg cursor-not-allowed"
  end

  def page_number_classes
    "inline-flex items-center px-4 py-2 text-sm font-medium text-gray-700 " \
      "bg-white border border-gray-300 rounded-lg hover:bg-gray-50 " \
      "focus:outline-none focus:ring-2 focus:ring-blue-500 transition-colors"
  end

  def current_page_classes
    "inline-flex items-center px-4 py-2 text-sm font-medium text-blue-700 " \
      "bg-blue-50 border border-blue-500 rounded-lg"
  end
end
