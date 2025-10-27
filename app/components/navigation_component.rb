# frozen_string_literal: true

class NavigationComponent < ApplicationComponent
  def initialize(
    logo_url: nil,
    logo_text: nil,
    menu_items: [],
    current_user: nil,
    account: nil,
    sticky: true,
    transparent: false
  )
    @logo_url = logo_url
    @logo_text = logo_text
    @menu_items = menu_items
    @current_user = current_user
    @account = account
    @sticky = sticky
    @transparent = transparent
  end

  def view_template
    nav(class: navigation_classes, data_controller: "navigation") do
      div(class: "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8") do
        div(class: "flex justify-between items-center h-16") do
          render_logo_section
          render_desktop_menu
          render_user_section
          render_mobile_menu_button
        end
      end
      render_mobile_menu
    end
  end

  private

  def navigation_classes
    base = "border-b border-gray-200"
    position = @sticky ? "sticky top-0 z-50" : ""
    background = @transparent ? "bg-transparent" : "bg-white"
    "#{base} #{position} #{background}"
  end

  def render_logo_section
    div(class: "flex items-center") do
      a(href: "/", class: "flex items-center space-x-2") do
        if @logo_url
          img(src: @logo_url, alt: "Logo", class: "h-8 w-auto")
        end
        span(class: "text-xl font-bold text-gray-900") do
          @logo_text || @account&.name || "App"
        end
      end
    end
  end

  def render_desktop_menu
    div(class: "hidden md:flex md:items-center md:space-x-8 ml-10") do
      @menu_items.each do |item|
        render_menu_item(item)
      end
    end
  end

  def render_menu_item(item)
    if item[:children]
      render_dropdown_menu(item)
    else
      a(
        href: item[:url],
        class: "text-gray-700 hover:text-blue-600 px-3 py-2 text-sm font-medium " \
               "transition-colors duration-200"
      ) { item[:text] }
    end
  end

  def render_dropdown_menu(item)
    div(class: "relative", data_controller: "dropdown") do
      button(
        type: "button",
        class: "text-gray-700 hover:text-blue-600 px-3 py-2 text-sm font-medium " \
               "inline-flex items-center transition-colors duration-200",
        data_action: "click->dropdown#toggle"
      ) do
        span { item[:text] }
        render_chevron_icon
      end

      div(
        class: "hidden absolute left-0 mt-2 w-48 rounded-md shadow-lg bg-white ring-1 " \
               "ring-black ring-opacity-5",
        data_dropdown_target: "menu"
      ) do
        div(class: "py-1") do
          item[:children].each do |child|
            a(
              href: child[:url],
              class: "block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 " \
                     "transition-colors duration-200"
            ) { child[:text] }
          end
        end
      end
    end
  end

  def render_chevron_icon
    svg(
      class: "ml-1 h-4 w-4",
      xmlns: "http://www.w3.org/2000/svg",
      viewBox: "0 0 20 20",
      fill: "currentColor"
    ) do |s|
      s.path(
        fill_rule: "evenodd",
        d: "M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z",
        clip_rule: "evenodd"
      )
    end
  end

  def render_user_section
    div(class: "hidden md:flex md:items-center md:space-x-4") do
      if @current_user
        render_user_dropdown
      else
        render_auth_buttons
      end
    end
  end

  def render_user_dropdown
    div(class: "relative", data_controller: "dropdown") do
      button(
        type: "button",
        class: "flex items-center space-x-2 text-sm rounded-full focus:outline-none " \
               "focus:ring-2 focus:ring-offset-2 focus:ring-blue-500",
        data_action: "click->dropdown#toggle"
      ) do
        render AvatarComponent.new(
          initials: @current_user.email[0].upcase,
          size: :sm
        )
        span(class: "ml-2 text-gray-700 font-medium") { @current_user.email }
        render_chevron_icon
      end

      div(
        class: "hidden absolute right-0 mt-2 w-48 rounded-md shadow-lg bg-white ring-1 " \
               "ring-black ring-opacity-5",
        data_dropdown_target: "menu"
      ) do
        div(class: "py-1") do
          render_user_menu_items
        end
      end
    end
  end

  def render_user_menu_items
    [
      {text: "Profile", url: helpers.edit_user_registration_path},
      {text: "Settings", url: "/settings"},
      {text: "Sign out", url: helpers.destroy_user_session_path, method: :delete}
    ].each do |item|
      if item[:method]
        form(action: item[:url], method: :post) do
          button(
            type: "submit",
            class: "block w-full text-left px-4 py-2 text-sm text-gray-700 " \
                   "hover:bg-gray-100 transition-colors duration-200"
          ) { item[:text] }
        end
      else
        a(
          href: item[:url],
          class: "block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 " \
                 "transition-colors duration-200"
        ) { item[:text] }
      end
    end
  end

  def render_auth_buttons
    div(class: "flex items-center space-x-4") do
      a(
        href: helpers.new_user_session_path,
        class: "text-gray-700 hover:text-blue-600 px-3 py-2 text-sm font-medium " \
               "transition-colors duration-200"
      ) { "Sign in" }
      a(
        href: helpers.new_user_registration_path,
        class: "bg-blue-600 text-white hover:bg-blue-700 px-4 py-2 rounded-lg " \
               "text-sm font-medium transition-colors duration-200"
      ) { "Sign up" }
    end
  end

  def render_mobile_menu_button
    button(
      type: "button",
      class: "md:hidden inline-flex items-center justify-center p-2 rounded-md " \
             "text-gray-700 hover:text-blue-600 hover:bg-gray-100 " \
             "focus:outline-none focus:ring-2 focus:ring-inset focus:ring-blue-500",
      data_action: "click->navigation#toggleMobile"
    ) do
      render_hamburger_icon
    end
  end

  def render_hamburger_icon
    svg(
      class: "h-6 w-6",
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewBox: "0 0 24 24",
      stroke: "currentColor"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        stroke_width: "2",
        d: "M4 6h16M4 12h16M4 18h16"
      )
    end
  end

  def render_mobile_menu
    div(
      class: "hidden md:hidden border-t border-gray-200",
      data_navigation_target: "mobileMenu"
    ) do
      div(class: "px-2 pt-2 pb-3 space-y-1") do
        @menu_items.each do |item|
          a(
            href: item[:url],
            class: "block px-3 py-2 rounded-md text-base font-medium text-gray-700 " \
                   "hover:text-blue-600 hover:bg-gray-100 transition-colors duration-200"
          ) { item[:text] }
        end
      end

      if @current_user
        div(class: "pt-4 pb-3 border-t border-gray-200") do
          div(class: "flex items-center px-5 mb-3") do
            render AvatarComponent.new(
              initials: @current_user.email[0].upcase,
              size: :sm
            )
            span(class: "ml-3 text-base font-medium text-gray-700") do
              @current_user.email
            end
          end
          render_mobile_user_menu
        end
      else
        div(class: "pt-4 pb-3 border-t border-gray-200 px-2 space-y-1") do
          render_auth_buttons
        end
      end
    end
  end

  def render_mobile_user_menu
    div(class: "px-2 space-y-1") do
      [
        {text: "Profile", url: helpers.edit_user_registration_path},
        {text: "Settings", url: "/settings"},
        {text: "Sign out", url: helpers.destroy_user_session_path, method: :delete}
      ].each do |item|
        if item[:method]
          form(action: item[:url], method: :post) do
            button(
              type: "submit",
              class: "block w-full text-left px-3 py-2 rounded-md text-base " \
                     "font-medium text-gray-700 hover:text-blue-600 hover:bg-gray-100 " \
                     "transition-colors duration-200"
            ) { item[:text] }
          end
        else
          a(
            href: item[:url],
            class: "block px-3 py-2 rounded-md text-base font-medium text-gray-700 " \
                   "hover:text-blue-600 hover:bg-gray-100 transition-colors duration-200"
          ) { item[:text] }
        end
      end
    end
  end

  def helpers
    ApplicationController.helpers
  end
end
