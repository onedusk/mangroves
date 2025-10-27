# frozen_string_literal: true

class ButtonComponent < ApplicationComponent
  ALLOWED_TYPES = %i[button submit reset].freeze
  ALLOWED_VARIANTS = %i[default primary secondary danger].freeze
  ALLOWED_SIZES = %i[sm md lg].freeze

  def initialize(text, type: :button, variant: :default, size: :md, disabled: false)
    @text = validate_required(text, param_name: "text")
    @type = validate_enum(type, allowed: ALLOWED_TYPES, param_name: "type")
    @variant = validate_enum(variant, allowed: ALLOWED_VARIANTS, param_name: "variant")
    @size = validate_enum(size, allowed: ALLOWED_SIZES, param_name: "size")
    @disabled = !!disabled # Coerce to boolean
  end

  def view_template
    button(
      type: @type,
      class: "#{base_classes} #{variant_classes} #{size_classes}",
      disabled: @disabled
    ) { @text }
  end

  private

  def base_classes
    "font-medium rounded-lg focus:outline-none focus:ring-4"
  end

  def variant_classes
    case @variant
    when :primary
      "text-white bg-blue-700 hover:bg-blue-800 focus:ring-blue-300"
    when :secondary
      "text-gray-900 bg-white border border-gray-200 hover:bg-gray-100 hover:text-blue-700 focus:ring-gray-200"
    when :danger
      "text-white bg-red-700 hover:bg-red-800 focus:ring-red-300"
    else
      "text-white bg-gray-800 hover:bg-gray-900 focus:ring-gray-300"
    end
  end

  def size_classes
    case @size
    when :sm
      "px-3 py-2 text-sm"
    when :lg
      "px-5 py-3 text-base"
    else
      "px-4 py-2.5 text-sm"
    end
  end
end
