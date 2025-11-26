class CreateCheers < ActiveRecord::Migration[8.1]
  def change
    create_table :cheers do |t|
      t.text :content
      t.integer :sender_id
      t.integer :recipient_id

      t.timestamps
    end
  end
end
