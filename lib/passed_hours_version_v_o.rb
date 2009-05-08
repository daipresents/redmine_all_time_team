# To change this template, choose Tools | Templates
# and open the template in the editor.

class PassedHoursVersionVO
  def initialize
    @version_id = nil
    @version_name = nil
    @users = []
    @hours = []
  end

  attr_accessor :version_id, :version_name, :users, :hours
end
