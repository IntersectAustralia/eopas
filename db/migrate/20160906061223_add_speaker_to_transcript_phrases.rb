class AddSpeakerToTranscriptPhrases < ActiveRecord::Migration
  def change
    add_column :transcript_phrases, :speaker, :string
  end
end
