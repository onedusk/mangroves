# frozen_string_literal: true

class NavigationMenuComponent < ApplicationComponent
  def initialize(items:, current_path: nil, breadcrumbs: nil, orientation: :horizontal)
    @items = items
    @current_path = current_path
    @breadcrumbs = breadcrumbs
    @orientation = orientation
  end

  def view_template
    nav(
      aria: {label: "Main navigation"},
      data: {controller: "navigation-menu"},
      class: navigation_classes
    ) do
      render_breadcrumbs if @breadcrumbs
      render_menu_items
    end
  end

  private

  def navigation_classes
    base = "bg-white"
    if @orientation == :vertical
      "#{base} flex flex-col space-y-1 p-4"
    else
      "#{base} flex items-center space-x-1 border-b border-gray-200 px-4"
    end
  end

  def render_breadcrumbs
    return unless @breadcrumbs&.any?

    div(class: "mb-4 py-2 border-b border-gray-200") do
      render BreadcrumbComponent.new(@breadcrumbs)
    end
  end

  def render_menu_items
    @items.each do |item|
      if item[:type] == :separator
        render_separator
      elsif item[:type] == :heading
        render_heading(item)
      elsif item[:items]
        render_dropdown_item(item)
      else
        render_nav_item(item)
      end
    end
  end

  def render_nav_item(item)
    is_active = active?(item)

    a(
      href: item[:href],
      data: {
        navigation_menu_target: "item",
        active: is_active.to_s
      },
      aria: {current: (is_active ? "page" : nil)},
      class: nav_item_classes(item, is_active)
    ) do
      render_item_icon(item[:icon]) if item[:icon]
      span { item[:label] }
      render_badge(item[:badge]) if item[:badge]
    end
  end

  def render_dropdown_item(item)
    div(
      class: "relative",
      data: {controller: "navigation-menu-dropdown"}
    ) do
      button(
        type: "button",
        data: {
          action: "click->navigation-menu-dropdown#toggle",
          navigation_menu_dropdown_target: "trigger"
        },
        aria: {expanded: "false"},
        class: dropdown_trigger_classes(item)
      ) do
        render_item_icon(item[:icon]) if item[:icon]
        span { item[:label] }
        render_chevron_icon
      end

      div(
        data: {navigation_menu_dropdown_target: "content"},
        class: dropdown_content_classes
      ) do
        item[:items].each do |subitem|
          render_dropdown_subitem(subitem)
        end
      end
    end
  end

  def render_dropdown_subitem(item)
    is_active = active?(item)

    a(
      href: item[:href],
      data: {
        navigation_menu_target: "item",
        active: is_active.to_s
      },
      aria: {current: (is_active ? "page" : nil)},
      class: dropdown_subitem_classes(is_active)
    ) do
      render_item_icon(item[:icon]) if item[:icon]
      span { item[:label] }
      render_badge(item[:badge]) if item[:badge]
    end
  end

  def render_separator
    if @orientation == :vertical
      div(role: "separator", class: "my-2 h-px bg-gray-200")
    else
      div(role: "separator", class: "mx-2 h-6 w-px bg-gray-200")
    end
  end

  def render_heading(item)
    div(class: "px-3 py-2 text-xs font-semibold text-gray-500 uppercase") do
      item[:label]
    end
  end

  def render_item_icon(icon)
    span(class: "text-gray-400") { icon }
  end

  def render_badge(badge)
    span(
      class: "ml-auto inline-flex items-center px-2 py-0.5 text-xs font-medium " \
             "rounded-full bg-blue-100 text-blue-800"
    ) do
      badge
    end
  end

  def render_chevron_icon
    svg(
      class: "ml-auto h-4 w-4 transition-transform",
      xmlns: "http://www.w3.org/2000/svg",
      viewBox: "0 0 20 20",
      fill: "currentColor",
      aria: {hidden: "true"}
    ) do |s|
      s.path(
        fill_rule: "evenodd",
        d: "M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 " \
           "111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z",
        clip_rule: "evenodd"
      )
    end
  end

  def active?(item)
    return false unless @current_path && item[:href]

    if item[:match_exact]
      @current_path == item[:href]
    else
      @current_path.start_with?(item[:href])
    end
  end

  def nav_item_classes(item, is_active)
    base = "flex items-center gap-2 px-3 py-2 text-sm font-medium rounded-lg " \
           "transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500"

    if is_active
      "#{base} bg-blue-50 text-blue-700"
    elsif item[:disabled]
      "#{base} text-gray-400 cursor-not-allowed"
    else
      "#{base} text-gray-700 hover:bg-gray-100"
    end
  end

  def dropdown_trigger_classes(_item)
    "flex items-center gap-2 w-full px-3 py-2 text-sm font-medium rounded-lg " \
      "text-gray-700 hover:bg-gray-100 transition-colors " \
      "focus:outline-none focus:ring-2 focus:ring-blue-500"
  end

  def dropdown_content_classes
    if @orientation == :vertical
      "hidden mt-1 ml-4 space-y-1"
    else
      "hidden absolute left-0 z-10 mt-2 w-56 origin-top-left rounded-md bg-white " \
        "shadow-lg ring-1 ring-black ring-opacity-5 py-1"
    end
  end

  def dropdown_subitem_classes(is_active)
    base = "flex items-center gap-2 px-3 py-2 text-sm rounded-lg " \
           "transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500"

    if is_active
      "#{base} bg-blue-50 text-blue-700 font-medium"
    else
      "#{base} text-gray-700 hover:bg-gray-100"
    end
  end
end
