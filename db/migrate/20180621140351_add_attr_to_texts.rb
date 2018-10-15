class AddAttrToTexts < ActiveRecord::Migration
  def change
    add_column :texts, :user_id, :integer
  end
end
