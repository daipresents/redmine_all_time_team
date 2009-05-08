require 'date'

class PassedHoursVO

  RECENT_WEEK = 4
  SUNDAY = 7
  WEEKEND = 6
  WEEK = 7
  
  def initialize
    @start_dates = []
    @end_dates = []
    @passed_hours_version_vo_list = []

    today = Date.today
    recent_sunday = today
    unless today.cwday == SUNDAY
      recent_sunday = today - today.cwday
    end
    
    count = 0
    while count < RECENT_WEEK
      @start_dates.unshift(recent_sunday)
      @end_dates.unshift(recent_sunday + WEEKEND)
      recent_sunday -= WEEK
      count += 1
    end
  end

  attr_accessor :start_dates, :end_dates, :passed_hours_version_vo_list
end
