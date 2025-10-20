# frozen_string_literal: true

class ToasterComponent < Phlex::HTML
  def initialize(position: :top_right)
    @position = position
  end

  def view_template(&)
    div(
      id: "toaster-container",
      class: "fixed z-50 #{position_classes}",
      data: {controller: "toaster"},
      aria_live: "polite",
      aria_atomic: "true"
    ) do
      div(
        class: "flex flex-col gap-3",
        data: {toaster_target: "container"},
        &
      )
    end
  end

  private

  def position_classes
    case @position
    when :top_left
      "top-4 left-4"
    when :top_center
      "top-4 left-1/2 -translate-x-1/2"
    when :top_right
      "top-4 right-4"
    when :bottom_left
      "bottom-4 left-4"
    when :bottom_center
      "bottom-4 left-1/2 -translate-x-1/2"
    when :bottom_right
      "bottom-4 right-4"
    else
      "top-4 right-4"
    end
  end
end
