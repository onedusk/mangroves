# frozen_string_literal: true

class AspectRatioComponent < Phlex::HTML
  RATIOS = {
    "16:9" => 56.25,   # 9/16 * 100
    "4:3" => 75,       # 3/4 * 100
    "1:1" => 100,      # 1/1 * 100
    "21:9" => 42.86,   # 9/21 * 100
    "3:2" => 66.67,    # 2/3 * 100
    "2:1" => 50        # 1/2 * 100
  }.freeze

  def initialize(ratio: "16:9")
    @ratio = ratio
    @padding_bottom = RATIOS[@ratio] || RATIOS["16:9"]
  end

  def view_template(&)
    div(class: "relative w-full", style: "padding-bottom: #{@padding_bottom}%") do
      div(class: "absolute inset-0", &)
    end
  end
end
