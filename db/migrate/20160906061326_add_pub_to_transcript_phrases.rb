class AddPubToTranscriptPhrases < ActiveRecord::Migration
  def change
    add_column :transcript_phrases, :pub, :string
  end
end
