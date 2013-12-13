class AddLoserToServer < ActiveRecord::Migration
  def change
    add_column :servers, :loser, :boolean
  end
end
