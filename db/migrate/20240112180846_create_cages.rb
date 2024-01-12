class CreateCages < ActiveRecord::Migration[7.1]
  def change
    create_table :cages do |t|
      t.string :name
      t.string :status, default: 'closed'
      t.timestamps
    end
  end
end
