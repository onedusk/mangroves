# frozen_string_literal: true

class ChartComponent < ApplicationComponent
  def view_template
    canvas(data: {controller: "chart"})
  end
end
