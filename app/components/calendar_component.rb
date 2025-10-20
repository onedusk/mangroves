# frozen_string_literal: true

class CalendarComponent < Phlex::HTML
  def template
    div(data: {controller: "calendar"})
  end
end
