# frozen_string_literal: true

class CheckboxComponent < ApplicationComponent
  def initialize(label:, checked: false)
    @label = label
    @checked = checked
  end

  def view_template
    label(class: "flex items-center") do
      input(type: "checkbox", class: "form-checkbox h-5 w-5 text-blue-600", checked: @checked)
      span(class: "ml-2 text-gray-700") { @label }
    end
  end
end
