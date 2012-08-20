class CreateRestaurants < ActiveRecord::Migration
  def self.up
    create_table :restaurants do |t|
      t.column :name, :string
      t.column :address, :text
      t.column :urban_spoon_id, :integer, :null => false
      t.column :online_res_avail, :integer, :null => false
      t.timestamps
    end
    
    create_table :reservations do |t|
      t.column :restaurant_id, :integer, :null => false
      t.column :reservation_time, :datetime, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :restaurants
    drop_table :reservations
  end
end