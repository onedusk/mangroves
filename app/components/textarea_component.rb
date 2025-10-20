# frozen_string_literal: true

class TextareaComponent < Phlex::HTML
  def initialize(
    name:,
    value: nil,
    placeholder: nil,
    disabled: false,
    required: false,
    rows: 3,
    resize: :vertical,
    max_length: nil,
    show_count: false,
    validation_state: nil,
    error_message: nil,
    hint: nil,
    label: nil,
    id: nil
  )
    @name = name
    @value = value
    @placeholder = placeholder
    @disabled = disabled
    @required = required
    @rows = rows
    @resize = resize
    @max_length = max_length
    @show_count = show_count
    @validation_state = validation_state
    @error_message = error_message
    @hint = hint
    @label = label
    @id = id || "textarea_#{name}"
  end

  def template
    div(class: "w-full") do
      if @label
        div(class: "flex justify-between items-center mb-1") do
          label(for: @id, class: "block text-sm font-medium text-gray-700") do
            plain @label
            if @required
              span(class: "text-red-500 ml-1") { "*" }
            end
          end

          if @show_count && @max_length
            span(
              class: "text-sm text-gray-500",
              data: {textarea_target: "counter"}
            ) do
              "#{@value&.length || 0}/#{@max_length}"
            end
          end
        end
      end

      textarea(
        name: @name,
        id: @id,
        placeholder: @placeholder,
        disabled: @disabled,
        required: @required,
        rows: @rows,
        maxlength: @max_length,
        class: textarea_classes,
        data: {
          controller: "textarea",
          action: "input->textarea#updateCount input->textarea#validate blur->textarea#validate",
          textarea_target: "field",
          textarea_max_length_value: @max_length,
          textarea_show_count_value: @show_count
        }
      ) { @value }

      if @hint && !@error_message
        p(class: "mt-1 text-sm text-gray-500") { @hint }
      end

      if @error_message
        p(class: "mt-1 text-sm text-red-600", data: {textarea_target: "error"}) { @error_message }
      end
    end
  end

  private

  def textarea_classes
    base = "block w-full rounded-md shadow-sm sm:text-sm"
    base += " focus:outline-none focus:ring-2"
    base += " #{resize_class}"

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

  def resize_class
    case @resize
    when :none
      "resize-none"
    when :horizontal
      "resize-x"
    when :both
      "resize"
    else
      "resize-y"
    end
  end
end
