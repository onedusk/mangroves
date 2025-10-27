# frozen_string_literal: true

class ToggleGroupComponent < ApplicationComponent
  def initialize(
    name:,
    items: [],
    selected: [],
    multiple: false,
    disabled: false,
    variant: :default,
    size: :md
  )
    @name = name
    @items = items
    @selected = Array(selected)
    @multiple = multiple
    @disabled = disabled
    @variant = variant
    @size = size
  end

  def view_template
    div(
      data: {
        controller: "toggle-group",
        toggle_group_multiple_value: @multiple,
        toggle_group_selected_value: @selected.to_json
      },
      class: "toggle-group inline-flex rounded-lg #{variant_container_classes}",
      role: "group"
    ) do
      @items.each_with_index do |item, index|
        render_toggle_item(item, index)
      end
    end
  end

  private

  def render_toggle_item(item, index)
    value = item.is_a?(Hash) ? item[:value] : item
    label = item.is_a?(Hash) ? item[:label] : item
    icon = item.is_a?(Hash) ? item[:icon] : nil
    item_disabled = @disabled || (item.is_a?(Hash) && item[:disabled])

    is_selected = @selected.include?(value.to_s) || @selected.include?(value)

    button(
      type: "button",
      data: {
        toggle_group_target: "item",
        action: "click->toggle-group#toggle",
        value: value
      },
      disabled: item_disabled,
      class: "#{item_base_classes} #{item_size_classes} #{item_state_classes(is_selected, item_disabled)} #{position_classes(index)}"
    ) do
      if icon
        span(class: "mr-2") { icon }
      end
      span { label }
    end
  end

  def variant_container_classes
    case @variant
    when :outline
      "border border-gray-300 dark:border-gray-600"
    else
      "bg-gray-100 dark:bg-gray-800"
    end
  end

  def item_base_classes
    "inline-flex items-center justify-center font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-blue-600 focus:ring-offset-2"
  end

  def item_size_classes
    case @size
    when :sm
      "px-3 py-1.5 text-xs"
    when :lg
      "px-6 py-3 text-base"
    else
      "px-4 py-2 text-sm"
    end
  end

  def item_state_classes(selected, disabled)
    if disabled
      "opacity-50 cursor-not-allowed text-gray-400 dark:text-gray-600"
    elsif selected
      case @variant
      when :outline
        "bg-blue-600 text-white dark:bg-blue-500"
      else
        "bg-white text-gray-900 shadow-sm dark:bg-gray-700 dark:text-white"
      end
    else
      case @variant
      when :outline
        "bg-transparent text-gray-700 hover:bg-gray-50 dark:text-gray-300 dark:hover:bg-gray-700"
      else
        "text-gray-700 hover:text-gray-900 dark:text-gray-400 dark:hover:text-white"
      end
    end
  end

  def position_classes(index)
    classes = []

    if index == 0
      classes << "rounded-l-lg"
    elsif index == @items.length - 1
      classes << "rounded-r-lg"
    end

    unless index == @items.length - 1
      classes << "border-r border-gray-200 dark:border-gray-700"
    end

    classes.join(" ")
  end
end
