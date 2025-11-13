class CreateClients < ActiveRecord::Migration[8.0]
  def change
    create_table :clients do |t|
      t.string :title

      t.timestamps
    end

    add_reference :users, :client
  end
end
