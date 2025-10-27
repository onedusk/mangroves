# frozen_string_literal: true

class CalendarComponent < ApplicationComponent
  def view_template
    div(data: {controller: "calendar"})
  end
end
