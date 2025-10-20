# frozen_string_literal: true

class ChartComponent < Phlex::HTML
  def template
    canvas(data: {controller: "chart"})
  end
end
