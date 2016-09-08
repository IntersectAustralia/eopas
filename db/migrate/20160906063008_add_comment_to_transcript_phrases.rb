class AddCommentToTranscriptPhrases < ActiveRecord::Migration
  def change
    add_column :transcript_phrases, :comment, :string
  end
end
