class AddRecentShotsFieldToBoards < ActiveRecord::Migration
  def change
    add_column :boards, :recent_shots_json, :text
  end
end
