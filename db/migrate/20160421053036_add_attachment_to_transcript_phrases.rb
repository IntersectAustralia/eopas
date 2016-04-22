class AddAttachmentToTranscriptPhrases < ActiveRecord::Migration
  def change
    add_column :transcript_phrases, :attachment, :string
  end
end
