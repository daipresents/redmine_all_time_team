require 'date'

class AllTimeTeamCommonLogic
  def self.get_members(project_id)
    return Member.find_by_sql(
      ["select members.user_id, users.lastname, users.firstname from members, users
          where
              members.user_id = users.id and users.type = 'User' and
              (members.project_id = :project_id or
              members.project_id in (select id from projects where parent_id = :project_id))
          group by members.user_id, users.lastname, users.firstname",
        {:project_id => project_id}])
  end

  def self.size_round(num, size)
    RAILS_DEFAULT_LOGGER.debug "round num = #{num.to_s}"

    num = num * (10 ** size)
    return num.round / (10.0 ** size)
  end

  def self.get_closed_num(version_id, is_closed)
    statuses = IssueStatus.find(:all, :conditions => ["is_closed = ?", is_closed == 1])
    num = 0
    unless statuses.nil?
      statuses.each do |status|
        num += Issue.count(:all, :conditions => ["fixed_version_id = ? and status_id =?", version_id, status.id])
      end
    end
    return num
  end

  def self.is_valid_version(version_id, effective_date)
      finish_num = get_closed_num(version_id, 1)
      unfinish_num = get_closed_num(version_id, 0)

      RAILS_DEFAULT_LOGGER.debug "finish_num = #{finish_num}"
      RAILS_DEFAULT_LOGGER.debug "unfinish_num = #{unfinish_num}"

      # closed version
      unless effective_date.nil?
        if effective_date < Date::today && finish_num == 0 && unfinish_num == 0
          return false
        end

        if effective_date < Date::today && finish_num >= 0 && unfinish_num == 0
          return false
        end
      end

      return true
  end
end
