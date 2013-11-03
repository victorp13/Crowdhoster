class Teamfund < ActiveRecord::Base
  attr_accessible :amount, :campaign_id, :user_email
end
