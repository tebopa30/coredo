class CreateHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :histories do |t|
      t.references :session, null: false, foreign_key: true
      t.references :dish, null: false, foreign_key: true
      t.datetime :decided_at

      t.timestamps
    end
  end
end
