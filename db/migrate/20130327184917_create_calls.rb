class CreateCalls < ActiveRecord::Migration
  def change
    create_table :calls do |t|
      t.integer :duration
      t.string :direction
      t.string :to
      t.string :from
      t.string :start_time
      t.string :network
      t.string :success

      t.timestamps
    end
  end
end
