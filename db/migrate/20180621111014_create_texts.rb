class CreateTexts < ActiveRecord::Migration
  def change
    create_table :texts do |t|
      t.string :title
      t.text :content
      t.integer :audio_id

      t.timestamps null: false
    end
  end
end
