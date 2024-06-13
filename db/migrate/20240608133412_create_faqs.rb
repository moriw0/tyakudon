class CreateFaqs < ActiveRecord::Migration[7.0]
  def change
    create_table :faqs do |t|
      t.string :question, null: false
      t.string :answer, null: false

      t.timestamps
    end
  end
end
