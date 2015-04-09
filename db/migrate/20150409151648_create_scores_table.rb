class CreateScoresTable < ActiveRecord::Migration
  def change
    create_table :scores do |t|
    	 t.timestamps
    	 t.integer :score
    	 t.integer :board_size
    	 t.integer :user_id
    end
  end
end
