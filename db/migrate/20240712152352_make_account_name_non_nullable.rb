class MakeAccountNameNonNullable < ActiveRecord::Migration[7.1]
  def change
    change_column_null :accounts, :name, false
  end
end
