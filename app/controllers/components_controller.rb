# frozen_string_literal: true

class ComponentsController < ApplicationController
  def alert_dialog
    render(
      AlertDialogComponent.new(
        title: params.fetch(:title, "Are you sure?"),
        content: params.fetch(:content, "This action cannot be undone.")
      )
    )
  end

  def dialog
    render(DialogComponent.new(title: "Dialog Title")) do
      "This is the dialog content."
    end
  end

  def drawer
    render(DrawerComponent.new(title: "Drawer Title")) do
      "This is the drawer content."
    end
  end
end
