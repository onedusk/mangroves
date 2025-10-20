# frozen_string_literal: true

class ScrollAreaComponent < Phlex::HTML
  def initialize(height: "400px", width: "100%", orientation: :vertical, class_name: nil)
    @height = height
    @width = width
    @orientation = orientation
    @class_name = class_name
  end

  def view_template(&)
    div(
      data: {controller: "scroll-area"},
      class: "scroll-area-root relative #{@class_name}".strip,
      style: "height: #{@height}; width: #{@width};"
    ) do
      div(
        data: {scroll_area_target: "viewport"},
        class: "scroll-area-viewport h-full w-full overflow-auto scrollbar-custom",
        style: scrollbar_styles
      ) do
        div(class: "scroll-area-content", &)
      end
    end
  end

  private

  def scrollbar_styles
    # Custom scrollbar styling for webkit browsers
    <<~CSS
      scrollbar-width: thin;
      scrollbar-color: rgb(156 163 175) transparent;
    CSS
  end
end
