class GroupsController < ApplicationController
  def index
    @tournament = Tournament.find params[:tournament_id]
    @groups = GroupsDecorator.decorate @tournament.groups.round_robin
  end
end
