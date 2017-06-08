class CreateTournamentTranslations < ActiveRecord::Migration[5.0]
  def self.up
    Tournament.create_translation_table!({
      :competition_mode => :text,
      :competition_fee => :text,
      :competition_schedule => :text
    }, {
      :migrate_data => true,
      :remove_source_columns => true
    })
  end

  def self.down
    Tournament.drop_translation_table! :migrate_data => true
  end
end
