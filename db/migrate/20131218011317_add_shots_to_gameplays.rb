class AddShotsToGameplays < ActiveRecord::Migration
  def change
    add_column :gameplays, :shots_json, :text
  end
end
