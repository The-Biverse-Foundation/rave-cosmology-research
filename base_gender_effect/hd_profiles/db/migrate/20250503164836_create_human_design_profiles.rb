class CreateHumanDesignProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :human_design_profiles do |t|
      t.string :gender
      t.integer :base

      t.timestamps
    end
  end
end
