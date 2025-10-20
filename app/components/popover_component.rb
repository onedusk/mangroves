# frozen_string_literal: true

class PopoverComponent < Phlex::HTML
  def initialize(trigger_content:, align: "center", side: "bottom", offset: 8)
    @trigger_content = trigger_content
    @align = align
    @side = side
    @offset = offset
  end

  def view_template(&content_block)
    div(
      data: {
        controller: "popover",
        popover_align_value: @align,
        popover_side_value: @side,
        popover_offset_value: @offset
      },
      class: "relative inline-block"
    ) do
      div(data: {popover_target: "trigger", action: "click->popover#toggle"}) do
        render_content(@trigger_content)
      end

      div(
        data: {popover_target: "content"},
        class: "hidden absolute z-50 bg-white rounded-md border border-gray-200 shadow-lg p-4"
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
