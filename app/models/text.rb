class Text < ActiveRecord::Base
    belongs_to :audio
    belongs_to :user
end
