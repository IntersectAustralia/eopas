class AddMorphToTranscriptPhrases < ActiveRecord::Migration
  def change
    add_column :transcript_phrases, :morph, :string
  end
end
