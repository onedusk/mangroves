# frozen_string_literal: true

class InputComponent < Phlex::HTML
  def initialize(
    name:,
    type: :text,
    value: nil,
    placeholder: nil,
    disabled: false,
    required: false,
    validation_state: nil,
    error_message: nil,
    hint: nil,
    label: nil,
    id: nil
  )
    @name = name
    @type = type
    @value = value
    @placeholder = placeholder
    @disabled = disabled
    @required = required
    @validation_state = validation_state
    @error_message = error_message
    @hint = hint
    @label = label
    @id = id || "input_#{name}"
  end

  def template
    div(class: "w-full") do
      if @label
        label(for: @id, class: "block text-sm font-medium text-gray-700 mb-1") do
          plain @label
          if @required
            span(class: "text-red-500 ml-1") { "*" }
          end
        end
      end

      input(
        type: @type,
        name: @name,
        id: @id,
        value: @value,
        placeholder: @placeholder,
        disabled: @disabled,
        required: @required,
        class: input_classes,
        data: {
          controller: "input",
          action: "input->input#validate blur->input#validate",
          input_target: "field"
        }
      )

      if @hint && !@error_message
        p(class: "mt-1 text-sm text-gray-500") { @hint }
      end

      if @error_message
        p(class: "mt-1 text-sm text-red-600", data: {input_target: "error"}) { @error_message }
      end
    end
  end

  private

  def input_classes
    base = "block w-full rounded-md shadow-sm sm:text-sm"
    base += " focus:outline-none focus:ring-2"

    case @validation_state
    when :error
      "#{base} border-red-300 text-red-900 placeholder-red-300 focus:ring-red-500 focus:border-red-500"
    when :success
      "#{base} border-green-300 text-green-900 focus:ring-green-500 focus:border-green-500"
    when :warning
      "#{base} border-yellow-300 text-yellow-900 focus:ring-yellow-500 focus:border-yellow-500"
    else
      "#{base} border-gray-300 focus:ring-blue-500 focus:border-blue-500"
    end + (@disabled ? " bg-gray-100 cursor-not-allowed" : "")
  end
end
