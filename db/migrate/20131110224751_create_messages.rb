class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.boolean :outgoing
      t.string :path
      t.text :inspected_data
      t.belongs_to :server, index: true
      t.belongs_to :in_response_to, index: true

      t.timestamps
    end
  end
end
