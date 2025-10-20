# frozen_string_literal: true

class MenubarComponent < Phlex::HTML
  def initialize(menus:)
    @menus = menus
  end

  def view_template
    nav(
      role: "menubar",
      aria: {label: "Main menu"},
      data: {controller: "menubar"},
      class: "flex items-center border-b border-gray-200 bg-white"
    ) do
      @menus.each do |menu|
        render_menu(menu)
      end
    end
  end

  private

  def render_menu(menu)
    div(
      class: "relative",
      data: {
        menubar_target: "menuContainer",
        controller: "dropdown-menu"
      }
    ) do
      render_menu_trigger(menu)
      render_menu_dropdown(menu)
    end
  end

  def render_menu_trigger(menu)
    button(
      type: "button",
      role: "menuitem",
      aria: {
        haspopup: "true",
        expanded: "false"
      },
      data: {
        action: "click->dropdown-menu#toggle mouseenter->menubar#handleHover focus->menubar#handleFocus",
        dropdown_menu_target: "trigger",
        menubar_target: "trigger"
      },
      class: menu_trigger_classes
    ) do
      span { menu[:label] }
    end
  end

  def menu_trigger_classes
    "px-4 py-3 text-sm font-medium text-gray-700 hover:bg-gray-100 " \
      "focus:outline-none focus:bg-gray-100 transition-colors"
  end

  def render_menu_dropdown(menu)
    div(
      data: {
        dropdown_menu_target: "menu",
        action: "keydown->dropdown-menu#handleMenuKeydown"
      },
      role: "menu",
      aria: {orientation: "vertical"},
      tabindex: "-1",
      class: dropdown_classes
    ) do
      div(class: "py-1", role: "none") do
        render_menu_items(menu[:items])
      end
    end
  end

  def dropdown_classes
    "hidden absolute left-0 z-10 mt-0 w-56 origin-top-left " \
      "rounded-md bg-white shadow-lg ring-1 ring-black ring-opacity-5 " \
      "focus:outline-none"
  end

  def render_menu_items(items)
    items.each do |item|
      if item[:type] == :separator
        render_separator
      elsif item[:type] == :heading
        render_heading(item)
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
        span { item[:label] }
      end
      render_shortcut(item[:shortcut]) if item[:shortcut]
    end
  end

  def render_separator
    div(role: "separator", class: "my-1 h-px bg-gray-200")
  end

  def render_heading(item)
    div(class: "px-4 py-2 text-xs font-semibold text-gray-500 uppercase") do
      item[:label]
    end
  end

  def render_icon(icon)
    span(class: "text-gray-400") { icon }
  end

  def render_shortcut(shortcut)
    kbd(class: "ml-auto text-xs text-gray-500") { shortcut }
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
end
