require 'date'
require 'common_logic'
require 'overwork_ranking_v_o'
require 'overwork_ranking_user_v_o'

class OverworkRankingLogic

  LIMIT_DAYS = 7
  
  def self.get_overwork_ranking(project_id)
    
    hours = get_hours(project_id)
    RAILS_DEFAULT_LOGGER.debug "hours = #{hours}"

    members = CommonLogic.get_members(project_id)
    RAILS_DEFAULT_LOGGER.debug "member_num = #{members.length}"
    
    vo = OverworkRankingVO.new
    if members.length != 0
      vo.average = CommonLogic.size_round(hours / members.length, 2)
      RAILS_DEFAULT_LOGGER.debug "average = #{vo.average}"
    end

    vo.users = get_users(project_id, vo.average)

    return vo
  end
  
  private
  def self.get_hours(project_id)
    results =
      TimeEntry.find_by_sql(
        ["select sum(hours) as sum from time_entries
          where (project_id = :project_id or
            project_id in (select id from projects where parent_id = :project_id)) and
            user_id in (select user_id from members where project_id = :project_id) and
            spent_on between :start_date and :end_date",
              {:project_id => project_id, :start_date => get_limit_date.to_s, :end_date => (Date.today - 1).to_s}])
          
    results.each do |result|
      return result.sum.to_f
    end

    return 0.0

  end

  private
  def self.get_users(project_id, avg)
    results =
      TimeEntry.find_by_sql(
        ["select users.id, users.lastname as name, sum(time_entries.hours) as hours from time_entries, users
          where time_entries.user_id = users.id and
            (time_entries.project_id = :project_id or
            time_entries.project_id in (select id from projects where parent_id = :project_id)) and
            time_entries.user_id in (select user_id from members where project_id = :project_id) and
            time_entries.spent_on between :start_date and :end_date
              group by users.lastname
              order by time_entries.hours desc",
        {:project_id => project_id, :start_date => get_limit_date.to_s, :end_date => (Date.today - 1).to_s}])

    users = []
    results.each do |result|
      vo = OverworkRankingUserVO.new

      if result.hours > (avg + 10)
        vo.contrast_img = 1
      elsif (avg - 10) <= result.hours && result.hours <= (avg + 10)
        vo.contrast_img = 2
      else
        vo.contrast_img = 3
      end

      vo.user_id = result.id
      vo.user_name = result.name
      vo.operating_hours = CommonLogic.size_round(result.hours, 2)
      contrast_hours = CommonLogic.size_round(result.hours - avg, 2)
      if 0 < contrast_hours
        vo.contrast_hours = "+" + contrast_hours.to_s
      elsif contrast_hours == 0
        vo.contrast_hours = "0"
      else
        vo.contrast_hours = contrast_hours.to_s
      end

      users.push(vo)
    end

    return users
  end

  private
  def self.get_limit_date
    return Date.today - LIMIT_DAYS
  end

end
