class CreateQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :questions do |t|
      t.string :text
      t.integer :order_index
      t.string :routing

      t.timestamps
    end
  end
end
