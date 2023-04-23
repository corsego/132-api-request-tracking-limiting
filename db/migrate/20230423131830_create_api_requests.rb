class CreateApiRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :api_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.string :path, null: false
      t.string :method, null: false

      t.timestamps
    end
  end
end
