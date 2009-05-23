require 'redmine'

Redmine::Plugin.register :redmine_all_time_team do
  name 'Redmine All Time Team plugin'
  author 'Dai Fujihara'
  description 'This is a plugin for Redmine'
  url 'http://daipresents.com/weblog/fujihalab/archives/2009/05/redmine-all-time-team-plugin.php'
  author_url 'http://daipresents.com/weblog/fujihalab/'

  requires_redmine :version_or_higher => '0.8.0'
  version '0.2.0'

  #permission :all_time_team, {:team_main => [:index]}, :public => true
  #permission :view_all_time_team, :team_main => :index
  project_module :all_time_team do
    permission :view_all_time_team, :all_time_team_main => :index
  end
  
  menu :project_menu, :all_time_team, { :controller => 'all_time_team_main', :action => 'index' },
  :caption => :all_time_team_name, :before => :roadmap, :param => :project_id
end
