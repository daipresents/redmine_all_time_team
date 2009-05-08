# To change this template, choose Tools | Templates
# and open the template in the editor.

class RecentActivityVO
  def initialize
    @user_id = nil
    @user_name = nil
    @activity_list = []
  end

  attr_accessor :user_id, :user_name, :activity_list
end
