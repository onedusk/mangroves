# frozen_string_literal: true

class DrawerComponent < Phlex::HTML
  def initialize(title:)
    @title = title
  end

  def template(&)
    div(data: {controller: "drawer"}, class: "fixed inset-0 overflow-hidden") do
      div(class: "absolute inset-0 overflow-hidden") do
        div(
          data: {action: "click->drawer#close"},
          class: "absolute inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
        )
        div(class: "fixed inset-y-0 right-0 pl-10 max-w-full flex") do
          div(
            data: {drawer_target: "panel"},
            class: "w-screen max-w-md transform transition ease-in-out duration-500 sm:duration-700"
          ) do
            div(class: "h-full flex flex-col py-6 bg-white shadow-xl overflow-y-scroll") do
              div(class: "px-4 sm:px-6") do
                div(class: "flex items-start justify-between") do
                  h2(class: "text-lg font-medium text-gray-900") { @title }
                  div(class: "ml-3 h-7 flex items-center") do
                    button(
                      data: {action: "drawer#close"},
                      class: "bg-white rounded-md text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                    ) do
                      span(class: "sr-only") { "Close panel" }
                      svg(
                        class: "h-6 w-6",
                        fill: "none",
                        viewBox: "0 0 24 24",
                        stroke: "currentColor",
                        aria_hidden: "true"
                      ) do
                        path(
                          stroke_linecap: "round",
                          stroke_linejoin: "round",
                          stroke_width: "2",
                          d: "M6 18L18 6M6 6l12 12"
                        )
                      end
                    end
                  end
                end
              end
              div(class: "mt-6 relative flex-1 px-4 sm:px-6", &)
            end
          end
        end
      end
    end
  end
end
