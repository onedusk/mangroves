# frozen_string_literal: true

class EnableUuid < ActiveRecord::Migration[8.0]
  def change
    enable_extension "pgcrypto"
    enable_extension "uuid-ossp"
  end
end
