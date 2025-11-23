class CreateAnswers < ActiveRecord::Migration[8.1]
  def change
    create_table :answers do |t|
      t.references :session, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.references :option, null: false, foreign_key: true

      t.timestamps
    end
  end
end
