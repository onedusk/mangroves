# frozen_string_literal: true

class CardComponent < ApplicationComponent
  def initialize(title: nil, footer: nil)
    @title = title
    @footer = footer
  end

  def view_template(&)
    div(class: "bg-white border border-gray-200 rounded-lg shadow") do
      if @title
        div(class: "p-4 border-b") do
          h5(class: "text-xl font-bold tracking-tight text-gray-900") { @title }
        end
      end
      div(class: "p-4", &)
      if @footer
        div(class: "p-4 border-t") do
          @footer
        end
      end
    end
  end
end
