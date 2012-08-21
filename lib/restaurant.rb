class Restaurant < ActiveRecord::Base
  has_many :reservations
  
  def has_nearest_reservations_within(time_frame = 7.days)
    today = Date.today
    nearest_reservations.each do |res|
      return true if (res - time_frame < Date.today)
    end
    false
  end
  
  def nearest_reservations
    rezs = reservations.map(&:reservation_time).sort
    ap rezs[0..2]
  end

  def reservation_distribution
    reservations = reservations.map do |res|
      res.reservation_time.strftime("%m-%d")
    end
    output_frequencies reservations
  end
end
