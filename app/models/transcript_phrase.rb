class TranscriptPhrase < ActiveRecord::Base
  belongs_to :transcript

  has_many :words, :class_name => 'TranscriptWord', :dependent => :destroy
  attr_accessible :attachment

  default_scope order(:start_time)

  # File system path to attachments folder, for dropzone to save uploaded images
  def self.store_dir
    File.join('public','system','attachment')
  end
  # Web path to attachment folder. Pass this as a data attr to the js for loading image into modal
  def self.public_dir
    File.join('system','attachment')
  end

  
  accepts_nested_attributes_for :words

  validates :start_time,  :presence => true, :numericality => true
  validates :end_time,    :presence => true, :numericality => true
  validates :phrase_id,   :presence => true
  validates :original,    :presence => true, :length => {:maximum => 4096}
  validates :translation, :length => {:maximum => 4096}
  validates :graid,       :length => {:maximum => 4096}
end
