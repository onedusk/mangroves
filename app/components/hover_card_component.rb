# frozen_string_literal: true

class HoverCardComponent < Phlex::HTML
  def initialize(trigger_content:, align: "center", side: "top", offset: 8, open_delay: 700, close_delay: 300)
    @trigger_content = trigger_content
    @align = align
    @side = side
    @offset = offset
    @open_delay = open_delay
    @close_delay = close_delay
  end

  def view_template(&content_block)
    div(
      data: {
        controller: "hover-card",
        hover_card_align_value: @align,
        hover_card_side_value: @side,
        hover_card_offset_value: @offset,
        hover_card_open_delay_value: @open_delay,
        hover_card_close_delay_value: @close_delay
      },
      class: "relative inline-block"
    ) do
      div(
        data: {
          hover_card_target: "trigger",
          action: "mouseenter->hover-card#scheduleOpen mouseleave->hover-card#scheduleClose"
        }
      ) do
        render_content(@trigger_content)
      end

      div(
        data: {
          hover_card_target: "content",
          action: "mouseenter->hover-card#cancelClose mouseleave->hover-card#scheduleClose"
        },
        class: "hidden absolute z-50 bg-white rounded-md border border-gray-200 shadow-lg p-4 w-64"
      ) do
        yield_content(&content_block) if content_block
      end
    end
  end

  private

  def render_content(content)
    case content
    when String
      plain content
    when Proc
      content.call
    else
      plain content.to_s
    end
  end
end
