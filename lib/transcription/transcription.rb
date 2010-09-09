
# provides functions to deal with import and export of
# interlinear text files in different formats

# validate
# transcode to EOPAS format
# import from EOPAS format into DB
# export to EOPAS format from DB
# transcode from EOPAS format

# supported formats:
# - elan
# - toolbox
# - transcriber

require 'nokogiri'
require 'fileutils'

class Transcription

  def initialize(options = {})
    @data = options[:data]
    @format = options[:format].downcase

    # parse XML file
    @doc = Nokogiri::XML(@data)
  end

  def validate
    # load Schema file
    xsdname = "#{Rails.root}/public/SCHEMAS/#@format.xsd"
    @xsd = Nokogiri::XML::Schema(File.open(xsdname))

    # validate doc and print errors
    @errors = @xsd.validate(@doc)
  end

  def errors
    @errors
  end

  def valid?
    @xsd.valid?(@doc)
  end

  def to_eopas

    # load correct XSLT
    xsltname = "#{Rails.root}/public/XSLT/#{@format}2eopas.xsl"
    @xslt  = Nokogiri::XSLT(File.open(xsltname))

    # transcode XML file
    @e_doc = @xslt.transform(@doc)

    # transcoding failed and just produced:
    # <?xml version="1.0" encoding="UTF-8"?>
    return if @e_doc == '<?xml version="1.0" encoding="UTF-8"?>'

    @e_doc.to_s
  end

  # parser class for Eopas 2.0 XML Documents
  class EopasDoc < Nokogiri::XML::SAX::Document
    def initialize(media_item, depositor)
      @media_item = media_item
      @depositor = depositor
      @transcript = Transcript.new(
        :media_item => media_item,
        :depositor  => depositor,
      )
      @in_phrase = false
    end

    def start_element(name, attrs = [])
      @tag = name
      attrs = Hash[*attrs]

      if @transcript.nil?
        puts "error: @transcript does not exist"
        return
      end

      case @tag
      when "eopas", "header", "interlinear-text"
        return

      when "meta"
        # the <meta> fields in the header
        case attrs['name']
        when "dc:type"
          @transcript.transcript_format = attrs['value']
        when "dc:creator"
          @transcript.creator = attrs['value']
        when "dc:language"
          @transcript.language_code = attrs['value']
        when "dc:date"
          @transcript.date = attrs['value']
        end
        return

      when "tier"
        # create new tier
        @tier = TranscriptTier.new(
          :transcript => @transcript
        )
        @tier.tier_id         = attrs['id'] if attrs['id']
        @tier.language_code   = attrs['lang'] if attrs['lang']
        @tier.linguistic_type = attrs['linguistic_type'] if attrs['linguistic_type']
        if attrs['parent'] && !attrs['parent'].empty?
          parent = TranscriptTier.find(:first, :conditions => {:tier_id => attrs['parent'], :transcript_id => @transcript.id})
          @tier.parent_id = parent.id if parent
        end
        @tier.save

      when "phrase"
        @in_phrase = true
        # create new phrase
        @phrase = TranscriptPhrase.new(
          :transcript_tier => @tier
        )
        @phrase.phrase_id       = attrs['id'] if attrs['id']
        @phrase.start_time      = attrs['startTime'].to_f if attrs['startTime']
        @phrase.end_time        = attrs['endTime'].to_f if attrs['endTime']
        @phrase.ref_phrase      = attrs['ref'] if attrs['ref']
        @phrase.participant     = attrs['participant'] if attrs['participant']
        @phrase.text = ""
      end
    end

    def end_element(name)
      @tag = name
      case @tag

      when "eopas", "header", "interlinear-text", "tier"
        return

      when "phrase"
        @phrase.save
        @in_phrase = false
      end
    end

    def characters(text)
      if @in_phrase
        @phrase.text += " "+text
        @phrase.text = @phrase.text.strip
      end
    end

    def end_document
      if @transcript.nil?
        puts "error: no transcription imported"
      else
        @transcript.save
      end
    end
  end

  def save_eopas(options = {})
    media_item = options[:media_item]
    depositor  = options[:depositor]
    eopas_file = options[:file]
    eopas_fd = File.open(eopas_file, 'rb')

    # set up SAX parser for EopasDoc
    parser = Nokogiri::XML::SAX::Parser.new(EopasDoc.new(media_item,depositor))

    # Send some XML to the parser
    parser.parse(eopas_fd.read)
  end

end
