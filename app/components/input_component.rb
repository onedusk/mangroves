# frozen_string_literal: true

class InputComponent < ApplicationComponent
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

  def view_template
    hint_id = "#{@id}_hint"
    error_id = "#{@id}_error"

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
        value: sanitized_value,
        placeholder: @placeholder,
        disabled: @disabled,
        required: @required,
        class: input_classes,
        aria: aria_attributes(hint_id, error_id),
        data: {
          controller: "input",
          action: "input->input#validate blur->input#validate",
          input_target: "field"
        }
      )

      if @hint && !@error_message
        p(id: hint_id, class: "mt-1 text-sm text-gray-500") { sanitize_text(@hint) }
      end

      if @error_message
        p(id: error_id, class: "mt-1 text-sm text-red-600", data: {input_target: "error"}) { plain @error_message }
      end
    end
  end

  private

  def aria_attributes(hint_id, error_id)
    attrs = {}

    # NOTE: ARIA invalid state for form validation
    attrs[:invalid] = "true" if @validation_state == :error

    # NOTE: ARIA required for form fields
    attrs[:required] = "true" if @required

    # NOTE: ARIA disabled for disabled inputs
    attrs[:disabled] = "true" if @disabled

    # NOTE: ARIA describedby for hint/error association
    described_by = []
    described_by << hint_id if @hint && !@error_message
    described_by << error_id if @error_message
    attrs[:describedby] = described_by.join(" ") if described_by.any?

    # NOTE: ARIA label for accessibility when no visible label
    attrs[:label] = sanitize_text(@label) if @label.present?

    attrs
  end

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

  def sanitized_value
    return nil if @value.nil?
    ERB::Util.html_escape(@value.to_s)
  end
end
