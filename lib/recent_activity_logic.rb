require 'common_logic'
require 'recent_activity_v_o'

class RecentActivityLogic

  LIMIT_DAYS = 7
  
  def self.get_recent_activity_vo_list(project_id)

    results = []
    CommonLogic.get_members(project_id).each do |member|

      vo = RecentActivityVO.new
      vo.user_id = member.user_id
      vo.user_name = member.lastname
      vo.activity_list =
        Journal.find_by_sql(
          ["select
              journals.created_on,
              issues.id as issue_id,
              issues.subject,
              journal_details.prop_key,
              journal_details.old_value,
              journal_details.value
              from
                journal_details
                left join journals on journals.id = journal_details.journal_id
                left join issues on journals.journalized_id = issues.id
              where
                (journal_details.prop_key = 'done_ratio' or
                journal_details.prop_key = 'status_id') and
                journals.created_on >= :limit_date and
                journals.user_id = :member_id
              order by journals.created_on desc",
            {:limit_date => (Date.today - LIMIT_DAYS).to_s, :member_id => member.user_id}])

      results.push(vo)
    end
    
    return results
    
  end
  
end
