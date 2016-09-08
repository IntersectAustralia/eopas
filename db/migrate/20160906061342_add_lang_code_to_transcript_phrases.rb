class AddLangCodeToTranscriptPhrases < ActiveRecord::Migration
  def change
    add_column :transcript_phrases, :lang_code, :string
  end
end
