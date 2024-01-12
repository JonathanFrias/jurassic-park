class CreateCages < ActiveRecord::Migration[7.1]
  def change
    create_table :cages do |t|

      t.timestamps
    end
  end
end
