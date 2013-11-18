class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.belongs_to :server, index: true
      t.text :representation_json

      t.timestamps
    end
  end
end
