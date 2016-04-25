class AddGlossToTranscriptPhrases < ActiveRecord::Migration
  def change
    add_column :transcript_phrases, :gloss, :string
  end
end
