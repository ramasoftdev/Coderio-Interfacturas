# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.integer :employee_id
      t.datetime :timestamp
      t.integer :kind

      t.timestamps
    end
  end
end
