ActiveAdmin.register Participant do
  permit_params do
    [:user_id, :tournament_id]
  end
end
