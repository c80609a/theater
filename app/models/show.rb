class Show < ApplicationRecord
  validates_presence_of :title,
                        :stop_at,
                        :start_at
end
