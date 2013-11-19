class CreateGameplays < ActiveRecord::Migration
  def change
    create_table :gameplays do |t|
      t.integer :board_width
      t.integer :board_height
      t.string :pieces_json
      t.string :result

      t.timestamps
    end
  end
end
