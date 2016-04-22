require 'RMagick'
require 'filemagic'

class TranscriptPhrasesController < ApplicationController

  filter_access_to :all

  def index
    @type = params[:type]
    @search = params[:search]
    language_code = params[:language_code]

    case @type
    when 'morpheme'
      @phrases = TranscriptPhrase.joins('
          INNER JOIN transcript_words ON transcript_words.transcript_phrase_id = transcript_phrases.id
          INNER JOIN transcript_morphemes ON transcript_morphemes.transcript_word_id = transcript_words.id
          INNER JOIN transcripts ON transcripts.id = transcript_phrases.transcript_id
      ').where('transcript_morphemes.morpheme' => @search).where('transcripts.language_code' => language_code)
    when 'word'
      @phrases = TranscriptPhrase.joins('
          INNER JOIN transcript_words ON transcript_words.transcript_phrase_id = transcript_phrases.id
          INNER JOIN transcripts ON transcripts.id = transcript_phrases.transcript_id
      ').where('transcript_words.word = ? collate utf8_bin', @search).where('transcripts.language_code' => language_code)
    end

    @phrases.sort_by(&:id).each {|p| p p.id}
    respond_to do |format|
      format.js { render :partial => "concordance" }
    end

  end

  def upload_attachment
    # get filenames for renaming to match the annotation
    original_filename = params[:file].original_filename
    attachment_name   = params[:attachment_name]
    # paths
    path = File.join(TranscriptPhrase.store_dir, params[:transcript_id], params[:phrase_id])
    image_full_path = File.join(path, attachment_name)
    # set up directories if needed
    FileUtils.mkdir_p(path) unless File.exists?(path)
    # save the file
    File.open(image_full_path, "wb") { |f| f.write(params[:file].read) }
    
    fm = FileMagic.new
    content_type = fm.file(image_full_path);
    logger.debug content_type

    valid = ['JPEG','JPG','PNG','GIF']
    r = /#{valid.join("|")}/

    if r === content_type
      # logger.debug "File is OK"
      # OK. Make a thumbnail
      thumbnail_path = File.join(TranscriptPhrase.store_dir, params[:transcript_id], params[:phrase_id], 'thumbnail')
      thumbnail_full_path = File.join(thumbnail_path, attachment_name)
      FileUtils.mkdir_p(thumbnail_path) unless File.exists?(thumbnail_path)
      img = Magick::Image.read(image_full_path).first
      thumbnail = img.crop_resized(100, 100)
      thumbnail.write thumbnail_full_path
      # Dropzone.js expects a json response
      render json: { msg: "success" }, status: 200
    else 
      # logger.debug "File is BAD"
      # File.delete(image_full_path) unless File.exists?(image_full_path)
      render json: { error: "bad file type" }, status: 400
    end

  end
end
