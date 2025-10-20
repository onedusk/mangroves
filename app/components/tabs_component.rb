# frozen_string_literal: true

class TabsComponent < Phlex::HTML
  def initialize(tabs:, default_tab: nil, orientation: :horizontal)
    @tabs = tabs
    @default_tab = default_tab || tabs.first[:id]
    @orientation = orientation
  end

  def view_template
    div(
      data: {
        controller: "tabs",
        tabs_default_value: @default_tab,
        tabs_orientation_value: @orientation
      },
      class: container_classes
    ) do
      render_tab_list
      render_tab_panels
    end
  end

  private

  def container_classes
    if @orientation == :vertical
      "flex gap-4"
    else
      "w-full"
    end
  end

  def render_tab_list
    div(
      role: "tablist",
      aria: {
        label: "Tabs",
        orientation: @orientation
      },
      data: {
        action: "keydown->tabs#handleKeydown",
        tabs_target: "tablist"
      },
      class: tablist_classes
    ) do
      @tabs.each_with_index do |tab, index|
        render_tab(tab, index)
      end
    end
  end

  def tablist_classes
    base = "border-gray-200"
    if @orientation == :vertical
      "#{base} flex flex-col space-y-1 border-r pr-4 min-w-[200px]"
    else
      "#{base} flex space-x-1 border-b"
    end
  end

  def render_tab(tab, _index)
    is_default = tab[:id] == @default_tab

    button(
      type: "button",
      role: "tab",
      id: "tab-#{tab[:id]}",
      aria: {
        selected: is_default.to_s,
        controls: "panel-#{tab[:id]}"
      },
      tabindex: is_default ? "0" : "-1",
      data: {
        action: "click->tabs#selectTab",
        tabs_target: "tab",
        tab_id: tab[:id]
      },
      class: tab_classes(is_default)
    ) do
      render_tab_icon(tab[:icon]) if tab[:icon]
      span { tab[:label] }
      render_badge(tab[:badge]) if tab[:badge]
    end
  end

  def render_tab_panels
    div(data: {tabs_target: "panels"}) do
      @tabs.each do |tab|
        render_tab_panel(tab)
      end
    end
  end

  def render_tab_panel(tab)
    is_default = tab[:id] == @default_tab

    div(
      role: "tabpanel",
      id: "panel-#{tab[:id]}",
      aria: {labelledby: "tab-#{tab[:id]}"},
      tabindex: "0",
      data: {
        tabs_target: "panel",
        panel_id: tab[:id]
      },
      class: panel_classes(is_default)
    ) do
      if tab[:content].is_a?(Proc)
        instance_exec(&tab[:content])
      else
        plain tab[:content]
      end
    end
  end

  def render_tab_icon(icon)
    span(class: "text-gray-400") { icon }
  end

  def render_badge(badge)
    span(
      class: "ml-2 inline-flex items-center px-2 py-0.5 text-xs font-medium " \
             "rounded-full bg-gray-100 text-gray-800"
    ) do
      badge
    end
  end

  def tab_classes(is_active)
    base = "inline-flex items-center gap-2 px-4 py-2 text-sm font-medium " \
           "transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500"

    if @orientation == :vertical
      border = "border-r-2"
      if is_active
        "#{base} #{border} border-blue-500 text-blue-700 bg-blue-50"
      else
        "#{base} #{border} border-transparent text-gray-600 hover:text-gray-900 hover:bg-gray-50"
      end
    else
      border = "border-b-2"
      if is_active
        "#{base} #{border} border-blue-500 text-blue-700"
      else
        "#{base} #{border} border-transparent text-gray-600 hover:text-gray-900 hover:border-gray-300"
      end
    end
  end

  def panel_classes(is_active)
    base = "py-4 focus:outline-none"
    is_active ? base : "#{base} hidden"
  end
end
