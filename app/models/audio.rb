class Audio < ActiveRecord::Base
    mount_uploader :title, TitleUploader    
    belongs_to :user
    has_many :texts, dependent: :destroy 

end
