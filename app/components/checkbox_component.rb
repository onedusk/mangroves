# frozen_string_literal: true

class CheckboxComponent < ApplicationComponent
  def initialize(name:, label:, checked: false, disabled: false, value: nil, id: nil, indeterminate: false)
    @name = name
    @label = label
    @checked = checked
    @disabled = disabled
    @value = value
    @id = id || name
    @indeterminate = indeterminate
  end

  def view_template
    label(class: "flex items-center", for: @id) do
      input_attrs = {
        type: "checkbox",
        name: @name,
        id: @id,
        class: "form-checkbox h-5 w-5 text-blue-600"
      }
      input_attrs[:checked] = true if @checked
      input_attrs[:disabled] = true if @disabled
      input_attrs[:value] = @value if @value
      input_attrs[:"data-indeterminate"] = true if @indeterminate

      input(**input_attrs)
      span(class: "ml-2 text-gray-700") { @label }
    end
  end
end
