require 'recent_activity_logic'
require 'overwork_ranking_logic'

class AllTimeTeamMainController < ApplicationController
  unloadable
  before_filter :init

  def index
    logger.debug "Recent Activity"
    @recent_activity_vo_list = RecentActivityLogic.get_recent_activity_vo_list(@project.id)
    
    logger.debug "Overwork Ranking"
    @overwork_ranking_vo = OverworkRankingLogic.get_overwork_ranking(@project.id)

    logger.debug "Recent Passed Hours"
    @passed_hours_vo = PassedHoursLogic.get_passed_hours_vo(@project.id)
  end

  def init
    @project_id = params[:project_id]
    @project = Project.find(@project_id)
  end
end
