class Call < ActiveRecord::Base
  attr_accessible :direction, :duration, :from, :network, :start_time, :success, :to
  
  validates :direction, :presence => true
  validates :duration, :presence => true
  validates :from, :presence => true
  validates :network, :presence => true
  validates :start_time, :presence => true
  validates :success, :presence => true
  validates :to, :presence => true
  
  before_save :cleanup
  
  private 
  
  def cleanup
    self[:from] = (self[:from][0] == 43  || self[:from][0] == '+') ? self[:from][1..self[:from].length] : self[:from]
    self[:to] = (self[:to][0] == 43  || self[:to][0] == '+') ? self[:to][1..self[:to].length] : self[:to]    
  end
end
