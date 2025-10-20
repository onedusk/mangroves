# frozen_string_literal: true

class SwitchComponent < Phlex::HTML
  def initialize(name:, checked: false, label: nil, label_position: :right, disabled: false)
    @name = name
    @checked = checked
    @label = label
    @label_position = label_position
    @disabled = disabled
  end

  def view_template
    label(
      class: "switch-container flex items-center gap-3 cursor-pointer #{"opacity-50 cursor-not-allowed" if @disabled}",
      data: {
        controller: "switch",
        switch_checked_value: @checked.to_s
      }
    ) do
      render_label if @label && @label_position == :left

      button(
        type: "button",
        role: "switch",
        aria_checked: @checked.to_s,
        disabled: @disabled,
        data: {
          action: "click->switch#toggle",
          switch_target: "button"
        },
        class: switch_classes
      ) do
        span(
          data: {switch_target: "thumb"},
          class: thumb_classes
        )
      end

      input(
        type: "hidden",
        name: @name,
        value: @checked.to_s,
        data: {switch_target: "input"}
      )

      render_label if @label && @label_position == :right
    end
  end

  private

  def render_label
    span(class: "text-sm font-medium text-gray-700") { @label }
  end

  def switch_classes
    base = "relative inline-flex h-6 w-11 flex-shrink-0 rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-blue-600 focus:ring-offset-2"
    state = @checked ? "bg-blue-600" : "bg-gray-200"
    "#{base} #{state}"
  end

  def thumb_classes
    base = "pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out"
    state = @checked ? "translate-x-5" : "translate-x-0"
    "#{base} #{state}"
  end
end
