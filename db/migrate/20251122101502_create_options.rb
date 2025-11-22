class CreateOptions < ActiveRecord::Migration[8.1]
  def change
    create_table :options do |t|
      t.references :question, null: false, foreign_key: true
      t.string :text
      t.integer :next_question_id
      t.integer :dish_id

      t.timestamps
    end
  end
end
