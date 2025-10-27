# frozen_string_literal: true

class RadioGroupComponent < ApplicationComponent
  def initialize(name:, options:, selected: nil, layout: :vertical, label: nil)
    @name = name
    @options = options
    @selected = selected
    @layout = layout
    @label = label
  end

  def view_template
    div(class: "radio-group") do
      label(class: "block text-sm font-medium text-gray-700 mb-2") { @label } if @label

      div(class: layout_classes) do
        @options.each do |option|
          render_radio_option(option)
        end
      end
    end
  end

  private

  def layout_classes
    case @layout
    when :horizontal
      "flex gap-4"
    else
      "flex flex-col gap-2"
    end
  end

  def render_radio_option(option)
    value, label_text = option.is_a?(Array) ? option : [option, option]

    label(class: "flex items-center cursor-pointer") do
      input(
        type: "radio",
        name: @name,
        value: value,
        checked: (@selected == value),
        class: "h-4 w-4 text-blue-600 border-gray-300 focus:ring-blue-500"
      )
      span(class: "ml-2 text-sm text-gray-700") { label_text }
    end
  end
end
