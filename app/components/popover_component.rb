# frozen_string_literal: true

class PopoverComponent < ApplicationComponent
  def initialize(trigger_content:, align: "center", side: "bottom", offset: 8)
    @trigger_content = trigger_content
    @align = align
    @side = side
    @offset = offset
    @popover_id = "popover_#{SecureRandom.hex(8)}"
  end

  def view_template(&)
    div(
      data: {
        controller: "popover",
        popover_align_value: @align,
        popover_side_value: @side,
        popover_offset_value: @offset
      },
      class: "relative inline-block"
    ) do
      div(
        data: {popover_target: "trigger", action: "click->popover#toggle"},
        role: "button",
        tabindex: "0",
        aria: {
          haspopup: "dialog",
          expanded: "false",
          controls: @popover_id
        }
      ) do
        render_content(@trigger_content)
      end

      div(
        id: @popover_id,
        role: "dialog",
        data: {popover_target: "content"},
        class: "hidden absolute z-50 bg-white rounded-md border border-gray-200 shadow-lg p-4",
        &
      )
    end
  end

  private

  def render_content(content)
    case content
    when String
      plain content
    when Proc
      # NOTE: XSS Protection - Execute Proc in safe context
      safe_proc(content)
    else
      plain content.to_s
    end
  end
end
