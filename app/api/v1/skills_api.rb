module V1
  class SkillsApi < BaseApi
    auth :grape_devise_token_auth, resource_class: :user

    helpers GrapeDeviseTokenAuth::AuthHelpers

    desc 'Get all skills'
    get 'skills' do
      skills = Skill.all
      present skills, with: Representers::SkillsRepresenter
    end
  end
end
