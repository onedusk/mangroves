# frozen_string_literal: true

class WorkspaceSwitcherComponent < Phlex::HTML
  def initialize(current_user:, current_workspace: nil)
    super()
    @current_user = current_user
    @current_workspace = current_workspace
  end

  def template
    div(class: "relative inline-block text-left") do
      render_trigger_button
      render_dropdown_menu
    end
  end

  private

  def render_trigger_button
    button(type: "button", class: trigger_button_classes) do
      span(class: "truncate") do
        if @current_workspace
          @current_workspace.name
        else
          span(class: "text-gray-400") { "Select workspace" }
        end
      end
      render_chevron_icon
    end
  end

  def trigger_button_classes
    "inline-flex justify-between items-center w-64 px-4 py-2 text-sm font-medium " \
      "text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 " \
      "focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
  end

  def render_chevron_icon
    svg(
      class: "ml-2 -mr-1 h-5 w-5",
      xmlns: "http://www.w3.org/2000/svg",
      viewBox: "0 0 20 20",
      fill: "currentColor"
    ) do |s|
      s.path(
        fill_rule: "evenodd",
        d: "M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 " \
           "111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z",
        clip_rule: "evenodd"
      )
    end
  end

  def render_dropdown_menu
    div(class: dropdown_menu_classes) do
      div(class: "py-1") do
        render_workspaces
      end
    end
  end

  def dropdown_menu_classes
    "origin-top-left absolute left-0 mt-2 w-64 rounded-md shadow-lg bg-white " \
      "ring-1 ring-black ring-opacity-5 max-h-96 overflow-y-auto"
  end

  def render_workspaces
    @current_user.accessible_accounts.each do |account|
      # Account header
      div(class: "px-4 py-2 text-xs font-semibold text-gray-500 uppercase bg-gray-50") do
        account.name
      end

      # Workspaces in account
      workspaces = account.workspaces.active
        .joins(:workspace_memberships)
        .where(workspace_memberships: {user_id: @current_user.id, status: :active})
        .distinct

      if workspaces.any?
        workspaces.each do |workspace|
          render_workspace_item(account, workspace)
        end
      else
        div(class: "px-4 py-2 text-sm text-gray-400 italic") do
          "No workspaces"
        end
      end
    end
  end

  def render_workspace_item(account, workspace)
    form(
      action: helpers.switch_account_workspace_path(account, workspace),
      method: "post",
      class: "block"
    ) do
      button(type: "submit", class: workspace_button_classes(workspace)) do
        render_workspace_button_content(workspace)
      end
    end
  end

  def render_workspace_button_content(workspace)
    div(class: "flex items-center justify-between") do
      span(class: "truncate") { workspace.name }
      render_check_icon if workspace == @current_workspace
    end
  end

  def render_check_icon
    svg(
      class: "ml-2 h-5 w-5 text-blue-600",
      xmlns: "http://www.w3.org/2000/svg",
      viewBox: "0 0 20 20",
      fill: "currentColor"
    ) do |s|
      s.path(
        fill_rule: "evenodd",
        d: "M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 " \
           "011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z",
        clip_rule: "evenodd"
      )
    end
  end

  def workspace_button_classes(workspace)
    base = "w-full text-left px-4 py-2 text-sm hover:bg-gray-100 " \
           "focus:outline-none focus:bg-gray-100 transition-colors duration-150"

    if workspace == @current_workspace
      "#{base} bg-blue-50 text-blue-700 font-medium"
    else
      "#{base} text-gray-700"
    end
  end

  def helpers
    # Access Rails URL helpers in Phlex
    ApplicationController.helpers
  end
end
