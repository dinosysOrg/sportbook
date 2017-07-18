ActiveAdmin.register Tournament do
  filter :name, filters: [:contains]

  index do
    id_column
    column :name
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :start_date
      row :end_date

      I18n.available_locales.each do |locale|
        Globalize.with_locale(locale) do
          row("#{I18n.t('activerecord.attributes.tournament.competition_mode')} (#{locale.to_s.upcase})", &:competition_mode)
          row("#{I18n.t('activerecord.attributes.tournament.competition_fee')} (#{locale.to_s.upcase})", &:competition_fee)
          row("#{I18n.t('activerecord.attributes.tournament.competition_schedule')} (#{locale.to_s.upcase})", &:competition_schedule)
        end
      end

      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :start_date, as: :date_picker
      f.input :end_date, as: :date_picker
      f.input :venues, as: :check_boxes
      f.translated_inputs switch_locale: false do |t|
        t.input :competition_mode, label: "#{I18n.t('activerecord.attributes.tournament.competition_mode')} (#{t.object.locale.to_s.upcase})",
                                   input_html: { class: 'summernote' }
        t.input :competition_fee, label: "#{I18n.t('activerecord.attributes.tournament.competition_fee')} (#{t.object.locale.to_s.upcase})",
                                  input_html: { class: 'summernote' }
        t.input :competition_schedule, label: "#{I18n.t('activerecord.attributes.tournament.competition_schedule')} (#{t.object.locale.to_s.upcase})",
                                       input_html: { class: 'summernote' }
      end
    end
    f.actions
  end

  permit_params do
    [:name, :start_date, :end_date, venue_ids: [], translations_attributes: [:id, :competition_mode, :competition_fee, :competition_schedule, :locale]]
  end
end
