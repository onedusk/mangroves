# frozen_string_literal: true

class FooterComponent < ApplicationComponent
  def initialize(
    account: nil,
    columns: [],
    copyright_text: nil,
    logo_url: nil,
    social_links: []
  )
    @account = account
    @columns = columns
    @copyright_text = copyright_text
    @logo_url = logo_url
    @social_links = social_links
  end

  def view_template
    footer(class: "bg-gray-900 text-white") do
      div(class: "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 sm:py-16") do
        render_footer_content
        render_footer_bottom
      end
    end
  end

  private

  def render_footer_content
    div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8 mb-8") do
      render_branding_column
      render_columns
    end
  end

  def render_branding_column
    div(class: "col-span-1 md:col-span-2 lg:col-span-1") do
      if @logo_url
        # NOTE: XSS Protection - Sanitize logo URL
        img(src: safe_url(@logo_url), alt: "Logo", class: "h-8 mb-4")
      elsif @account
        div(class: "text-xl font-bold mb-4") { plain @account.name }
      end

      if @account&.settings&.dig("footer_description")
        p(class: "text-gray-400 text-sm mb-4") do
          # NOTE: XSS Protection - Sanitize tenant-controlled content
          plain @account.settings["footer_description"]
        end
      end

      render_social_links
    end
  end

  def render_columns
    @columns.each do |column|
      div(class: "col-span-1") do
        h3(class: "text-sm font-semibold uppercase tracking-wider mb-4") do
          plain column[:title]
        end
        ul(class: "space-y-3") do
          column[:links]&.each do |link|
            li do
              a(
                href: safe_url(link[:url]),
                class: "text-gray-400 hover:text-white transition-colors duration-200 text-sm"
              ) { plain link[:text] }
            end
          end
        end
      end
    end
  end

  def render_social_links
    return if @social_links.empty?

    div(class: "flex space-x-4") do
      @social_links.each do |social|
        a(
          href: safe_url(social[:url]),
          class: "text-gray-400 hover:text-white transition-colors duration-200",
          target: "_blank",
          rel: "noopener noreferrer",
          aria_label: sanitize_text(social[:label])
        ) do
          render_social_icon(social[:icon])
        end
      end
    end
  end

  def render_social_icon(icon_name)
    svg(class: "h-6 w-6", fill: "currentColor", viewBox: "0 0 24 24") do |s|
      case icon_name
      when :twitter
        s.path(d: "M8.29 20.251c7.547 0 11.675-6.253 11.675-11.675 0-.178 0-.355-.012-.53A8.348 8.348 0 0022 5.92a8.19 8.19 0 01-2.357.646 4.118 4.118 0 001.804-2.27 8.224 8.224 0 01-2.605.996 4.107 4.107 0 00-6.993 3.743 11.65 11.65 0 01-8.457-4.287 4.106 4.106 0 001.27 5.477A4.072 4.072 0 012.8 9.713v.052a4.105 4.105 0 003.292 4.022 4.095 4.095 0 01-1.853.07 4.108 4.108 0 003.834 2.85A8.233 8.233 0 012 18.407a11.616 11.616 0 006.29 1.84")
      when :github
        s.path(fill_rule: "evenodd", d: "M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z", clip_rule: "evenodd")
      when :linkedin
        s.path(fill_rule: "evenodd", d: "M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.79-1.75-1.764s.784-1.764 1.75-1.764 1.75.79 1.75 1.764-.783 1.764-1.75 1.764zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z", clip_rule: "evenodd")
      end
    end
  end

  def render_footer_bottom
    div(class: "border-t border-gray-800 pt-8 flex flex-col sm:flex-row justify-between items-center") do
      render_copyright
      render_footer_links
    end
  end

  def render_copyright
    p(class: "text-gray-400 text-sm mb-4 sm:mb-0") do
      if @copyright_text
        plain @copyright_text
      elsif @account
        plain "© #{Time.current.year} #{@account.name}. All rights reserved."
      else
        plain "© #{Time.current.year} All rights reserved."
      end
    end
  end

  def render_footer_links
    div(class: "flex space-x-6") do
      a(href: "/privacy", class: "text-gray-400 hover:text-white text-sm transition-colors duration-200") do
        "Privacy Policy"
      end
      a(href: "/terms", class: "text-gray-400 hover:text-white text-sm transition-colors duration-200") do
        "Terms of Service"
      end
    end
  end
end
