# frozen_string_literal: true

class SkeletonComponent < ApplicationComponent
  def initialize(variant: :text, width: nil, height: nil, count: 1, space_y: 2)
    @variant = variant
    @width = width
    @height = height
    @count = count
    @space_y = space_y
  end

  def view_template
    if @count > 1
      div(class: "space-y-#{@space_y}") do
        @count.times { render_skeleton }
      end
    else
      render_skeleton
    end
  end

  private

  def render_skeleton
    div(
      class: "#{base_classes} #{variant_classes}",
      style: custom_styles,
      aria_hidden: "true"
    )
  end

  def base_classes
    "animate-pulse bg-gray-200 rounded"
  end

  def variant_classes
    case @variant
    when :circle
      "rounded-full"
    when :rectangle
      "rounded-none"
    when :text
      "rounded h-4"
    when :heading
      "rounded h-8"
    when :avatar
      "rounded-full h-10 w-10"
    when :button
      "rounded-md h-10"
    when :card
      "rounded-lg h-48"
    else
      "rounded h-4"
    end
  end

  def custom_styles
    styles = []
    styles << "width: #{@width}" if @width
    styles << "height: #{@height}" if @height
    styles.join("; ") if styles.any?
  end
end
