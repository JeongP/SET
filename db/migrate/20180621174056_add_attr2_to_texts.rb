class AddAttr2ToTexts < ActiveRecord::Migration
  def change
    add_column :texts, :lang, :string
    add_column :texts, :phase1, :string
    add_column :texts, :phase2, :string
    add_column :texts, :phase3, :string
  end
end
