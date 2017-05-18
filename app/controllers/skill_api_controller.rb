class SkillApiController < ApplicationController
  def index
    render json: Skill.all
  end
end
