# frozen_string_literal: true

class SeparatorComponent < Phlex::HTML
  def initialize(orientation: :horizontal, decorative: true, class_name: nil)
    @orientation = orientation
    @decorative = decorative
    @class_name = class_name
  end

  def view_template
    div(
      role: (@decorative ? "none" : "separator"),
      aria_orientation: @orientation.to_s,
      class: "#{base_classes} #{orientation_classes} #{@class_name}".strip
    )
  end

  private

  def base_classes
    "bg-gray-200 dark:bg-gray-700"
  end

  def orientation_classes
    case @orientation
    when :vertical
      "w-px h-full min-h-4"
    else
      "h-px w-full"
    end
  end
end
