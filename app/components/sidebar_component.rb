# frozen_string_literal: true

class SidebarComponent < ApplicationComponent
  def initialize(
    sections:,
    current_user: nil,
    current_workspace: nil,
    collapsible: true,
    show_workspace_switcher: true
  )
    @sections = sections
    @current_user = current_user
    @current_workspace = current_workspace
    @collapsible = collapsible
    @show_workspace_switcher = show_workspace_switcher
  end

  def view_template
    aside(
      data: {
        controller: "sidebar",
        sidebar_collapsible_value: @collapsible.to_s
      },
      aria: {label: "Sidebar navigation"},
      class: sidebar_classes
    ) do
      render_header
      render_workspace_switcher if @show_workspace_switcher && @current_user
      render_sections
      render_footer
    end
  end

  private

  def sidebar_classes
    "flex flex-col h-full bg-white border-r border-gray-200 transition-all duration-300"
  end

  def render_header
    div(class: "flex items-center justify-between px-4 py-4 border-b border-gray-200") do
      div(
        data: {sidebar_target: "logo"},
        class: "flex items-center gap-2"
      ) do
        # Logo or app name
        h2(class: "text-lg font-semibold text-gray-900") { "Mangroves" }
      end

      if @collapsible
        button(
          type: "button",
          data: {
            action: "click->sidebar#toggle",
            sidebar_target: "collapseButton"
          },
          aria: {label: "Toggle sidebar"},
          class: "p-2 text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-lg " \
                 "transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500"
        ) do
          render_collapse_icon
        end
      end
    end
  end

  def render_workspace_switcher
    div(class: "px-4 py-3 border-b border-gray-200") do
      div(data: {sidebar_target: "workspaceSwitcher"}) do
        render WorkspaceSwitcherComponent.new(
          current_user: @current_user,
          current_workspace: @current_workspace
        )
      end
    end
  end

  def render_sections
    nav(
      class: "flex-1 overflow-y-auto px-3 py-4",
      data: {sidebar_target: "navigation"}
    ) do
      @sections.each do |section|
        render_section(section)
      end
    end
  end

  def render_section(section)
    div(class: "mb-6") do
      if section[:title]
        render_section_header(section)
      end

      div(
        data: {
          sidebar_target: "sectionContent",
          section_id: section[:id]
        },
        class: "space-y-1"
      ) do
        render_section_items(section[:items])
      end
    end
  end

  def render_section_header(section)
    if section[:collapsible]
      button(
        type: "button",
        data: {
          action: "click->sidebar#toggleSection",
          sidebar_target: "sectionHeader",
          section_id: section[:id]
        },
        aria: {
          expanded: section[:expanded] == false ? "false" : "true"
        },
        class: "flex items-center justify-between w-full px-3 py-2 text-xs font-semibold " \
               "text-gray-500 uppercase hover:text-gray-700 transition-colors " \
               "focus:outline-none focus:ring-2 focus:ring-blue-500 rounded-lg"
      ) do
        span(data: {sidebar_target: "sectionTitle"}) { section[:title] }
        render_chevron_icon
      end
    else
      div(class: "px-3 py-2 text-xs font-semibold text-gray-500 uppercase") do
        span(data: {sidebar_target: "sectionTitle"}) { section[:title] }
      end
    end
  end

  def render_section_items(items)
    items.each do |item|
      if item[:type] == :separator
        render_separator
      else
        render_nav_item(item)
      end
    end
  end

  def render_nav_item(item)
    a(
      href: item[:href],
      data: {
        sidebar_target: "navItem",
        active: (item[:active] ? "true" : "false")
      },
      aria: {current: (item[:active] ? "page" : nil)},
      class: nav_item_classes(item)
    ) do
      div(class: "flex items-center gap-3") do
        render_item_icon(item[:icon]) if item[:icon]
        span(data: {sidebar_target: "itemLabel"}) { item[:label] }
      end
      render_badge(item[:badge]) if item[:badge]
    end
  end

  def render_separator
    div(role: "separator", class: "my-2 h-px bg-gray-200")
  end

  def render_footer
    div(
      class: "px-4 py-3 border-t border-gray-200",
      data: {sidebar_target: "footer"}
    ) do
      # Footer content (e.g., user profile, settings)
    end
  end

  def render_item_icon(icon)
    span(class: "flex-shrink-0 text-gray-400") { icon }
  end

  def render_badge(badge)
    span(
      class: "ml-auto inline-flex items-center px-2 py-0.5 text-xs font-medium " \
             "rounded-full bg-blue-100 text-blue-800"
    ) do
      badge
    end
  end

  def render_collapse_icon
    svg(
      class: "h-5 w-5",
      xmlns: "http://www.w3.org/2000/svg",
      viewBox: "0 0 20 20",
      fill: "currentColor",
      aria: {hidden: "true"}
    ) do |s|
      s.path(
        fill_rule: "evenodd",
        d: "M3 5a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 5a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 5a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z",
        clip_rule: "evenodd"
      )
    end
  end

  def render_chevron_icon
    svg(
      class: "h-4 w-4 transition-transform",
      data: {sidebar_target: "chevron"},
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

  def nav_item_classes(item)
    base = "flex items-center justify-between px-3 py-2 text-sm font-medium rounded-lg " \
           "transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500"

    if item[:active]
      "#{base} bg-blue-50 text-blue-700"
    elsif item[:disabled]
      "#{base} text-gray-400 cursor-not-allowed"
    else
      "#{base} text-gray-700 hover:bg-gray-100"
    end
  end
end
