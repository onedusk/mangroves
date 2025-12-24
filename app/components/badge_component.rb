# frozen_string_literal: true

class BadgeComponent < ApplicationComponent
  def initialize(text, variant: :default)
    @text = text
    @variant = variant
  end

  def view_template
    span(class: badge_classes) { @text }
  end

  private

  def badge_classes
    base = "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
    variant = case @variant
              when :success then "bg-green-100 text-green-800"
              when :warning then "bg-yellow-100 text-yellow-800"
              when :error then "bg-red-100 text-red-800"
              when :info then "bg-blue-100 text-blue-800"
              when :dark then "bg-gray-700 text-gray-100"
              when :red then "bg-red-100 text-red-800"
              when :green then "bg-green-100 text-green-800"
              when :yellow then "bg-yellow-100 text-yellow-800"
              when :indigo then "bg-indigo-100 text-indigo-800"
              when :purple then "bg-purple-100 text-purple-800"
              when :pink then "bg-pink-100 text-pink-800"
              else "bg-gray-100 text-gray-800"
              end
    "#{base} #{variant}"
  end
end
