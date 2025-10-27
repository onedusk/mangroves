# frozen_string_literal: true

class ToggleComponent < ApplicationComponent
  def initialize(
    name:,
    checked: false,
    disabled: false,
    label: nil,
    icon_on: nil,
    icon_off: nil,
    size: :md
  )
    @name = name
    @checked = checked
    @disabled = disabled
    @label = label
    @icon_on = icon_on
    @icon_off = icon_off
    @size = size
  end

  def view_template
    div(class: "toggle-wrapper inline-flex items-center gap-2") do
      button(
        type: "button",
        role: "switch",
        aria_checked: @checked.to_s,
        data: {
          controller: "toggle",
          toggle_checked_value: @checked,
          action: "click->toggle#toggle"
        },
        disabled: @disabled,
        class: "#{base_classes} #{size_classes} #{state_classes}"
      ) do
        span(
          data: {toggle_target: "thumb"},
          class: "#{thumb_classes} #{thumb_size_classes}"
        ) do
          if @icon_on || @icon_off
            span(
              data: {toggle_target: "icon"},
              class: icon_classes.to_s
            ) do
              @checked ? (@icon_on || "") : (@icon_off || "")
            end
          end
        end
      end

      # Hidden input to submit value
      input(
        type: "hidden",
        name: @name,
        value: @checked ? "1" : "0",
        data: {toggle_target: "input"}
      )

      # Optional label
      if @label
        label(class: "text-sm font-medium text-gray-900 dark:text-white") { @label }
      end
    end
  end

  private

  def base_classes
    "relative inline-flex items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-blue-600 focus:ring-offset-2"
  end

  def size_classes
    case @size
    when :sm
      "h-5 w-9"
    when :lg
      "h-8 w-14"
    else
      "h-6 w-11"
    end
  end

  def state_classes
    if @disabled
      "opacity-50 cursor-not-allowed bg-gray-200 dark:bg-gray-700"
    elsif @checked
      "bg-blue-600 dark:bg-blue-500"
    else
      "bg-gray-200 dark:bg-gray-700"
    end
  end

  def thumb_classes
    "inline-flex items-center justify-center bg-white rounded-full shadow-sm transform transition-transform"
  end

  def thumb_size_classes
    case @size
    when :sm
      "h-4 w-4 #{@checked ? "translate-x-4" : "translate-x-0.5"}"
    when :lg
      "h-7 w-7 #{@checked ? "translate-x-6" : "translate-x-0.5"}"
    else
      "h-5 w-5 #{@checked ? "translate-x-5" : "translate-x-0.5"}"
    end
  end

  def icon_classes
    "text-gray-400 dark:text-gray-500"
  end
end
