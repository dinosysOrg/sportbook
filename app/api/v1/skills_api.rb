module V1
  class SkillsApi < BaseApi
    auth :grape_devise_token_auth, resource_class: :user

    helpers GrapeDeviseTokenAuth::AuthHelpers
    helpers V1::Helpers

    desc 'Get all skills'
    params do
      optional :locale, type: String, default: 'vi', desc: "Language which server returns. Value is 'vi' or 'en'"
    end
    get 'skills' do
      skills = Skill.all
      present skills, with: Representers::SkillsRepresenter
    end
  end
end
