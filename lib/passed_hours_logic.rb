require 'passed_hours_v_o'
require 'passed_hours_version_v_o'
require 'common_logic'

class PassedHoursLogic
  def self.get_passed_hours_vo(project_id)

    versions = get_versions(project_id)

    vo = PassedHoursVO.new

    versions.each do |version|
      next unless CommonLogic.is_valid_version(version.id, version.effective_date)

      version_vo = PassedHoursVersionVO.new
      version_vo.version_id =  version.id
      version_vo.version_name = version.name
      version_vo.users = get_version_users(version.id)
      version_vo.hours = get_version_hours(vo, version.id)
      version_vo.max_hours = version_vo.hours[version_vo.hours.length - 1]
      vo.passed_hours_version_vo_list.push(version_vo)
    end

    vo.passed_hours_version_vo_list = vo.passed_hours_version_vo_list.sort{|aa, bb|
      bb.max_hours <=>  aa.max_hours
    }

    return vo

  end

  private
  def self.get_versions(project_id)
    results = Version.find_by_sql(
            ["select id, name, effective_date from versions
                where
                   project_id = :project_id or
                   project_id in (select id from projects where parent_id = :project_id)
                group by versions.name
                order by name asc",
                  {:project_id => project_id}])
    if results.nil?
      return []
    else
      return results
    end
  end

  private
  def self.get_version_hours(vo, version_id)
    results = []
    count = 0
    while count < vo.start_dates.length
      start_date = vo.start_dates[count]
      end_date = vo.end_dates[count]

      hours = Issue.find_by_sql(
        ["select sum(hours) as version_hours from issues, time_entries
            where
              issues.id = time_entries.issue_id and
              issues.fixed_version_id = :version_id and
              time_entries.spent_on between :start_date and :end_date",
              {:version_id => version_id, :start_date => start_date, :end_date => end_date}])

      if hours.nil?
        results.push(0.0)
      else
        hours.each do |hour|
          results.push(CommonLogic.size_round(hour.version_hours.to_f, 2))
        end
      end
      
      count += 1
    end

    return results
  end

  private
  def self.get_version_users(version_id)
    users = Issue.find_by_sql([
      "select users.id, users.lastname, count(issues.id) as count from issues, time_entries, users
        where
          issues.id = time_entries.issue_id and
          issues.assigned_to_id = users.id and
          issues.fixed_version_id = :version_id
        group by users.id",
        {:version_id => version_id}])
    
    if users.nil?
      return []
    else
      return users
    end
  end

end
