# frozen_string_literal: true

class ContextMenuComponent < Phlex::HTML
  def initialize(items)
    @items = items
  end

  def template(&)
    div(data: {controller: "context-menu"}) do
      div(data: {action: "contextmenu->context-menu#show"}, &)
      div(data: {context_menu_target: "menu"}, class: "hidden absolute bg-white border rounded-md shadow-lg") do
        @items.each do |item|
          a(href: item[:href], class: "block px-4 py-2 text-gray-700 hover:bg-gray-100") { item[:name] }
        end
      end
    end
  end
end
