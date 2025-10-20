# frozen_string_literal: true

class ButtonComponent < Phlex::HTML
  def initialize(text, type: :button, variant: :default, size: :md, disabled: false)
    @text = text
    @type = type
    @variant = variant
    @size = size
    @disabled = disabled
  end

  def template
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
