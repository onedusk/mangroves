# frozen_string_literal: true

class DropdownMenuComponent < ApplicationComponent
  def initialize(items:, trigger_text: "Menu", align: :left, width: "w-56")
    @items = items
    @trigger_text = trigger_text
    @align = align
    @width = width
    @menu_id = "dropdown_menu_#{SecureRandom.hex(8)}"
  end

  def view_template
    div(
      data: {
        controller: "dropdown-menu",
        dropdown_menu_align_value: @align
      },
      class: "relative inline-block text-left"
    ) do
      render_trigger_button
      render_dropdown_content
    end
  end

  private

  def render_trigger_button
    button(
      type: "button",
      data: {
        action: "click->dropdown-menu#toggle keydown->dropdown-menu#handleTriggerKeydown",
        dropdown_menu_target: "trigger"
      },
      aria: {
        haspopup: "true",
        expanded: "false",
        controls: @menu_id
      },
      class: trigger_button_classes
    ) do
      span { plain @trigger_text }
      render_chevron_icon
    end
  end

  def trigger_button_classes
    "inline-flex justify-between items-center gap-2 px-4 py-2 text-sm font-medium " \
      "text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 " \
      "focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
  end

  def render_chevron_icon
    svg(
      class: "h-5 w-5",
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

  def render_dropdown_content
    div(
      id: @menu_id,
      data: {
        dropdown_menu_target: "menu",
        action: "keydown->dropdown-menu#handleMenuKeydown"
      },
      role: "menu",
      aria: {orientation: "vertical"},
      tabindex: "-1",
      class: dropdown_menu_classes
    ) do
      div(class: "py-1", role: "none") do
        render_items(@items)
      end
    end
  end

  def dropdown_menu_classes
    align_class = @align == :right ? "right-0" : "left-0"
    "hidden absolute #{align_class} z-10 mt-2 #{@width} origin-top-#{@align} " \
      "rounded-md bg-white shadow-lg ring-1 ring-black ring-opacity-5 " \
      "focus:outline-none"
  end

  def render_items(items, depth = 0)
    items.each do |item|
      if item[:type] == :separator
        render_separator
      elsif item[:type] == :heading
        render_heading(item)
      elsif item[:items]
        render_submenu_item(item, depth)
      else
        render_menu_item(item)
      end
    end
  end

  def render_menu_item(item)
    if item[:href]
      a(
        href: item[:href],
        role: "menuitem",
        tabindex: "-1",
        data: {
          action: "click->dropdown-menu#handleItemClick",
          dropdown_menu_target: "item"
        },
        class: menu_item_classes(item)
      ) do
        render_item_content(item)
      end
    else
      button(
        type: "button",
        role: "menuitem",
        tabindex: "-1",
        data: {
          action: "click->dropdown-menu#handleItemClick",
          dropdown_menu_target: "item"
        },
        class: menu_item_classes(item)
      ) do
        render_item_content(item)
      end
    end
  end

  def render_item_content(item)
    div(class: "flex items-center justify-between w-full") do
      div(class: "flex items-center gap-2") do
        render_icon(item[:icon]) if item[:icon]
        span { plain item[:label] }
      end
      render_shortcut(item[:shortcut]) if item[:shortcut]
    end
  end

  def render_submenu_item(item, depth)
    div(
      class: "relative",
      data: {
        controller: "dropdown-menu",
        dropdown_menu_target: "submenu",
        action: "mouseenter->dropdown-menu#openSubmenu mouseleave->dropdown-menu#closeSubmenu"
      }
    ) do
      button(
        type: "button",
        role: "menuitem",
        tabindex: "-1",
        data: {
          action: "click->dropdown-menu#toggleSubmenu keydown->dropdown-menu#handleSubmenuKeydown",
          dropdown_menu_target: "submenuTrigger"
        },
        class: menu_item_classes(item)
      ) do
        div(class: "flex items-center justify-between w-full") do
          div(class: "flex items-center gap-2") do
            render_icon(item[:icon]) if item[:icon]
            span { plain item[:label] }
          end
          render_chevron_right_icon
        end
      end

      # Submenu content
      div(
        data: {dropdown_menu_target: "submenuContent"},
        role: "menu",
        aria: {orientation: "vertical"},
        tabindex: "-1",
        class: submenu_classes
      ) do
        div(class: "py-1", role: "none") do
          render_items(item[:items], depth + 1)
        end
      end
    end
  end

  def render_separator
    div(role: "separator", class: "my-1 h-px bg-gray-200")
  end

  def render_heading(item)
    div(class: "px-4 py-2 text-xs font-semibold text-gray-500 uppercase") do
      plain item[:label]
    end
  end

  def render_icon(icon)
    span(class: "text-gray-400") { icon }
  end

  def render_shortcut(shortcut)
    kbd(class: "ml-auto text-xs text-gray-500") { plain shortcut }
  end

  def render_chevron_right_icon
    svg(
      class: "h-4 w-4 text-gray-400",
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

  def menu_item_classes(item)
    base = "block w-full text-left px-4 py-2 text-sm transition-colors " \
           "focus:outline-none focus:bg-gray-100"

    if item[:disabled]
      "#{base} text-gray-400 cursor-not-allowed"
    elsif item[:destructive]
      "#{base} text-red-600 hover:bg-red-50"
    else
      "#{base} text-gray-700 hover:bg-gray-100"
    end
  end

  def submenu_classes
    "hidden absolute left-full top-0 ml-1 w-56 rounded-md bg-white shadow-lg " \
      "ring-1 ring-black ring-opacity-5 focus:outline-none z-10"
  end
end
