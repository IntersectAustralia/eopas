require 'transcription'

class ProperSchemaValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless record.new_record?
      return
    end
    transcription = record.instance_variable_get(:@transcription)
    if transcription.nil?
      record.errors[attribute] = 'Missing transcription'
    else
      errors = transcription.validate
      unless errors.empty?
        record.errors[attribute] << "Transcript did not validate against the schema"
        errors.each do |error|
          record.errors[attribute] << error.message
        end
      end
    end
  end
end

class Transcript < ActiveRecord::Base
  belongs_to :depositor, :class_name => 'User'
  belongs_to :media_item

  has_many :phrases, :class_name => 'TranscriptPhrase', :dependent => :destroy
  has_many :participants, :dependent => :destroy

  accepts_nested_attributes_for :participants, :allow_destroy => true, :reject_if => lambda { |participant| participant[:name].blank? }

  accepts_nested_attributes_for :phrases

  scope :are_private, where(:private => true)
  scope :are_public, where(:private => false)

  include Paperclip
  has_attached_file :original, :url => "/system/transcript/:attachment/:id/:style/:filename"

  attr_accessible :title, :date, :country_code, :language_code, :copyright, :license, :private, :original, :transcript_format, :participants_attributes

  FORMATS = ['ELAN', 'Toolbox', 'Transcriber', 'EOPAS']

  validates :original,          :presence => true, :proper_schema => true
  validates :transcript_format, :presence => true, :inclusion => { :in => FORMATS }
  validates :depositor,         :presence => true

  # Validated on second step
  validates :title,             :presence => true, :unless => lambda { new_record? }
  validates :date,              :presence => true, :unless => lambda { new_record? }
  validates :country_code,      :presence => true, :unless => lambda { new_record? }
  validates :language_code,      :presence => true, :unless => lambda { new_record? }

  validates_associated :depositor
  validates_attachment_presence :original

  before_validation :create_transcription, :on => :create

  def self.search(search)
    if search
      where(['title LIKE ?', "%#{search}%"])
    else
      scoped
    end
  end

  protected
  def create_transcription
    # FIXME find a better way of doing this
    if original_file_name
      file_path = original.to_file.path
      @transcription = Transcription.new(:data => File.read(file_path).force_encoding('UTF-8'), :format => transcript_format)
      @transcription.import self
    end
  end

end


