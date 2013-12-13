class AddWidthAndHeightColumnsToBoard < ActiveRecord::Migration
  def change

    add_column :boards, :height, :integer, :default => 8
    add_column :boards, :width, :integer, :default => 8


  end
end
