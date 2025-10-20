# frozen_string_literal: true

class ProgressComponent < Phlex::HTML
  def initialize(value: 0, max: 100, variant: :default, size: :md, indeterminate: false, label: nil)
    @value = value
    @max = max
    @variant = variant
    @size = size
    @indeterminate = indeterminate
    @label = label
  end

  def view_template
    div(class: "progress-component") do
      render_label if @label

      div(
        class: container_classes.to_s,
        role: "progressbar",
        aria_valuenow: @indeterminate ? nil : @value,
        aria_valuemin: @indeterminate ? nil : 0,
        aria_valuemax: @indeterminate ? nil : @max,
        aria_label: @label || "Progress"
      ) do
        div(
          class: bar_classes.to_s,
          style: @indeterminate ? nil : "width: #{percentage}%"
        )
      end
    end
  end

  private

  def render_label
    div(class: "flex justify-between items-center mb-2") do
      span(class: "text-sm font-medium text-gray-700") { @label }
      span(class: "text-sm font-medium text-gray-700") { "#{percentage.round}%" } unless @indeterminate
    end
  end

  def container_classes
    base = "w-full bg-gray-200 rounded-full overflow-hidden"
    "#{base} #{size_classes}"
  end

  def size_classes
    case @size
    when :sm
      "h-1"
    when :lg
      "h-4"
    else
      "h-2"
    end
  end

  def bar_classes
    base = "h-full transition-all duration-300 ease-in-out"
    color = variant_color
    animation = @indeterminate ? "animate-progress-indeterminate" : ""
    "#{base} #{color} #{animation}"
  end

  def variant_color
    case @variant
    when :success
      "bg-green-600"
    when :warning
      "bg-yellow-600"
    when :error
      "bg-red-600"
    when :info
      "bg-blue-600"
    else
      "bg-blue-600"
    end
  end

  def percentage
    return 0 if @max.zero?

    [(@value.to_f / @max * 100), 100].min
  end
end
