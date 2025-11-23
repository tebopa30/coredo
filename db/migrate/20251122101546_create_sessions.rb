class CreateSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions do |t|
      t.string :uuid
      t.datetime :started_at
      t.datetime :finished_at
      t.references :dish, null: false, foreign_key: true

      t.timestamps
    end
    add_index :sessions, :uuid
  end
end
