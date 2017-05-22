class AddSkillToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :skill_id, :integer
    add_foreign_key :users, :skills
  end
end
