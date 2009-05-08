# To change this template, choose Tools | Templates
# and open the template in the editor.

class CommonLogic
  def self.get_members(project_id)
    return Member.find_by_sql(
      ["select members.user_id, users.lastname from members, users
          where
              members.user_id = users.id and
              (members.project_id = :project_id or
              members.project_id in (select id from projects where parent_id = :project_id))
          group by user_id",
        {:project_id => project_id}])
  end

  def self.size_round(num, size)
    RAILS_DEFAULT_LOGGER.debug "round num = #{num.to_s}"

    num = num * (10 ** size)
    return num.round / (10.0 ** size)
  end
end
