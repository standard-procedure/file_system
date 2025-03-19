class CreateCars < ActiveRecord::Migration[8.0]
  def change
    create_table :cars do |t|
      t.string :make, default: "", null: false
      t.string :model, default: "", null: false
      t.timestamps
    end
  end
end
