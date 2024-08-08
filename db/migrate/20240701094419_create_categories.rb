# frozen_string_literal: true

class CreateCategories < ActiveRecord::Migration[7.1]
  def up
    create_enum :category_types, %w[expense income]

    create_table :categories do |t|
      t.string :name, null: false
      t.enum :category_type, enum_type: :category_types, null: false
      t.timestamps
    end
  end

  def down
    drop_table :categories

    execute <<-SQL.squish
      DROP TYPE category_types;
    SQL
  end
end
