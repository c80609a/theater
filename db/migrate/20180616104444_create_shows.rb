class CreateShows < ActiveRecord::Migration[5.2]
  def change
    create_table :shows do |t|
      t.string :title
      t.date :start_at
      t.date :stop_at

      t.timestamps
    end
  end
end
