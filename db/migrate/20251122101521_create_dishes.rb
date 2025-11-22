class CreateDishes < ActiveRecord::Migration[8.1]
  def change
    create_table :dishes do |t|
      t.string :name
      t.text :description
      t.string :genre
      t.string :recipe_url

      t.timestamps
    end
  end
end
