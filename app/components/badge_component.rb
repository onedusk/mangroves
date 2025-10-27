# frozen_string_literal: true

class BadgeComponent < ApplicationComponent
  def initialize(text, color: :default)
    @text = text
    @color = color
  end

  def view_template
    span(class: "#{color_classes} text-xs font-medium me-2 px-2.5 py-0.5 rounded-full") { @text }
  end

  private

  def color_classes
    case @color
    when :dark
      "bg-gray-700 text-gray-100"
    when :red
      "bg-red-100 text-red-800"
    when :green
      "bg-green-100 text-green-800"
    when :yellow
      "bg-yellow-100 text-yellow-800"
    when :indigo
      "bg-indigo-100 text-indigo-800"
    when :purple
      "bg-purple-100 text-purple-800"
    when :pink
      "bg-pink-100 text-pink-800"
    else
      "bg-blue-100 text-blue-800"
    end
  end
end
