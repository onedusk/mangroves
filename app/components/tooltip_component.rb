# frozen_string_literal: true

class TooltipComponent < Phlex::HTML
  def initialize(text:, position: "top", delay: 200)
    @text = text
    @position = position
    @delay = delay
  end

  def view_template(&)
    div(
      data: {
        controller: "tooltip",
        tooltip_position_value: @position,
        tooltip_delay_value: @delay
      },
      class: "relative inline-block"
    ) do
      div(
        data: {
          tooltip_target: "trigger",
          action: "mouseenter->tooltip#show mouseleave->tooltip#hide focus->tooltip#show blur->tooltip#hide"
        },
        &
      )

      div(
        data: {tooltip_target: "content"},
        class: "hidden absolute z-50 px-2 py-1 text-xs text-white bg-gray-900 rounded whitespace-nowrap"
      ) do
        plain @text

        # Arrow
        div(
          data: {tooltip_target: "arrow"},
          class: "absolute w-2 h-2 bg-gray-900 transform rotate-45"
        )
      end
    end
  end
end
