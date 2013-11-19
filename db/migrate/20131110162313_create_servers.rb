class CreateServers < ActiveRecord::Migration
  def change
    create_table :servers do |t|
      t.string :hostname
      t.string :current_role
      t.boolean :winner

      t.timestamps
    end
  end
end
