# frozen_string_literal: true

class SliderComponent < ApplicationComponent
  def initialize(
    name:,
    min: 0,
    max: 100,
    step: 1,
    value: nil,
    range: false,
    range_values: nil,
    disabled: false,
    show_value: true
  )
    @name = name
    @min = min
    @max = max
    @step = step
    @value = value || min
    @range = range
    @range_values = range_values || [min, (min + max) / 2]
    @disabled = disabled
    @show_value = show_value
  end

  def view_template
    div(
      data: {
        controller: "slider",
        slider_min_value: @min,
        slider_max_value: @max,
        slider_step_value: @step,
        slider_range_value: @range,
        slider_disabled_value: @disabled
      },
      class: "slider-container w-full"
    ) do
      if @show_value
        div(class: "flex justify-between mb-2 text-sm text-gray-600 dark:text-gray-400") do
          span(data: {slider_target: "minLabel"}) { @min.to_s }
          span(data: {slider_target: "valueLabel"}, class: "font-medium text-gray-900 dark:text-white") do
            @range ? "#{@range_values[0]} - #{@range_values[1]}" : @value.to_s
          end
          span(data: {slider_target: "maxLabel"}) { @max.to_s }
        end
      end

      div(class: "relative h-2 bg-gray-200 dark:bg-gray-700 rounded-full") do
        div(
          data: {slider_target: "track"},
          class: "absolute h-full bg-blue-600 dark:bg-blue-500 rounded-full",
          style: track_style
        )

        if @range
          render_range_thumbs
        else
          render_single_thumb
        end
      end

      # Hidden input(s) to submit values
      if @range
        input(
          type: "hidden",
          name: "#{@name}[min]",
          value: @range_values[0],
          data: {slider_target: "inputMin"}
        )
        input(
          type: "hidden",
          name: "#{@name}[max]",
          value: @range_values[1],
          data: {slider_target: "inputMax"}
        )
      else
        input(
          type: "hidden",
          name: @name,
          value: @value,
          data: {slider_target: "input"}
        )
      end
    end
  end

  private

  def render_single_thumb
    div(
      data: {
        slider_target: "thumb",
        action: "mousedown->slider#startDrag touchstart->slider#startDrag"
      },
      class: "absolute top-1/2 -translate-y-1/2 w-5 h-5 bg-white border-2 border-blue-600 rounded-full cursor-pointer shadow-md #{disabled_classes}",
      style: thumb_style
    )
  end

  def render_range_thumbs
    div(
      data: {
        slider_target: "thumbMin",
        action: "mousedown->slider#startDragMin touchstart->slider#startDragMin"
      },
      class: "absolute top-1/2 -translate-y-1/2 w-5 h-5 bg-white border-2 border-blue-600 rounded-full cursor-pointer shadow-md z-10 #{disabled_classes}",
      style: "left: #{percentage(@range_values[0])}%; transform: translate(-50%, -50%);"
    )

    div(
      data: {
        slider_target: "thumbMax",
        action: "mousedown->slider#startDragMax touchstart->slider#startDragMax"
      },
      class: "absolute top-1/2 -translate-y-1/2 w-5 h-5 bg-white border-2 border-blue-600 rounded-full cursor-pointer shadow-md z-10 #{disabled_classes}",
      style: "left: #{percentage(@range_values[1])}%; transform: translate(-50%, -50%);"
    )
  end

  def track_style
    if @range
      "left: #{percentage(@range_values[0])}%; width: #{percentage(@range_values[1]) - percentage(@range_values[0])}%;"
    else
      "width: #{percentage(@value)}%;"
    end
  end

  def thumb_style
    "left: #{percentage(@value)}%; transform: translate(-50%, -50%);"
  end

  def percentage(value)
    ((value.to_f - @min) / (@max - @min) * 100).round(2)
  end

  def disabled_classes
    @disabled ? "opacity-50 cursor-not-allowed" : ""
  end
end
