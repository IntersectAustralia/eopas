<?xml version="1.0" encoding="UTF-8"?>
<!--
Transforms flextext xml into eopas xml
By John Mansfield, University of Melbourne, 10 August 2015
Modified by Ben Foley, for Myfany Turpin's Ken Hale Kaytetye Corpus, 5 Sep 2016

Works with flex text with notes. So start in Elan with Phrases, Translations and Notes, then import to Flex.
Gloss and export a flextext file containing the words, morphemes and glosses, and notes fields.
If notes have special symbols, we write attributes to the phrase element,
which eopas will use when importing to decide what to import.
If notes contain:
*PUB - the words from a phrase with this code in notes will not be imported by eopas
p123 - eopas will store this value in the attachments column, and use it as an image src by appending .jpg
KH   - this will be stored as the phrase record's speaker column
WA   - this will be the phrase's language

USAGE EXAMPLES
CLI, using Saxon:
java -jar -Xmx1024m /Library/SaxonHE9-4-0-4J/saxon9he.jar -t SOURCEPATH/SOURCE.flextext scripts/flex-to-eopas.xsl > TARGETPATH/SOURCE_eopas.xml
EOPAS:
rails runner bin/transcode.rb features/test_data/kh4560.flextext Flex
or upload a flextext file using EOPAS Upload Transcript feature
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/">

	<!--xsl:output indent="no" media-type="xml"/-->
	<xsl:output indent="yes" media-type="xml"/>

	<xsl:preserve-space elements="*"/>

	<xsl:template match="document">
		<eopas>
			<xsl:element name="header">
				<xsl:element name="meta">
					<xsl:attribute name="name">
						<xsl:text>dc:type</xsl:text>
					</xsl:attribute>
					<xsl:attribute name="value">
						<xsl:text>text/xml</xsl:text>
					</xsl:attribute>
				</xsl:element>
				<xsl:element name="meta">
					<xsl:attribute name="name">
						<xsl:text>dc:language</xsl:text>
					</xsl:attribute>
					<xsl:attribute name="value">
						<xsl:apply-templates select="interlinear-text/paragraphs/paragraph[1]/phrases[1]/phrase[1]/item[@type = 'txt']/@lang"/>
					</xsl:attribute>
				</xsl:element>
			</xsl:element>
			<xsl:element name="interlinear">
        <xsl:apply-templates select="interlinear-text/paragraphs/paragraph/phrases/phrase"/>
			</xsl:element>
		</eopas>
	</xsl:template>

	<xsl:template match="phrase">
    <xsl:variable name="i" select="position()" />
    <xsl:element name="phrase">

      <!-- phrase ID needs to be non-numeric -->
      <xsl:attribute name="id">
        <xsl:value-of select="concat('a',$i)"/>
			</xsl:attribute>

      <!-- Create speaker/lang_code/pub/pdf attributes based on note field symbols -->
      <xsl:for-each select="./item[@type = 'note']">
            <xsl:choose>
              <xsl:when test="(. = 'KH') or (. = 'LW')">
                <xsl:attribute name="speaker">
                  <xsl:value-of select="normalize-space(.)"/>
                </xsl:attribute>
              </xsl:when>
              <xsl:when test="(. = 'EN') or (. = 'KA') or (. = 'WA')">
                <xsl:attribute name="lang_code">
                  <xsl:value-of select="normalize-space(.)"/>
                </xsl:attribute>
              </xsl:when>
              <xsl:when test=". = '*PUB'">
                <xsl:attribute name="pub">
                  <xsl:value-of select="normalize-space(.)"/>
                </xsl:attribute>
              </xsl:when>
              <xsl:when test=". = contains(., '.jpg')">
                <xsl:attribute name="jpg">
                  <xsl:value-of select="normalize-space(.)"/>
                </xsl:attribute>
              </xsl:when>
            </xsl:choose>
      </xsl:for-each>

      <!-- need to convert times from ms -->
      <xsl:variable name="startTime_VALUE" select="./@begin-time-offset"/>
      <xsl:variable name="endTime_VALUE" select="./@end-time-offset"/>
      <xsl:variable name="Milliseconds_CONST" select="1000"/>
      <xsl:variable name="startTime_Seconds" select="$startTime_VALUE div $Milliseconds_CONST"/>
      <xsl:variable name="endTime_Seconds" select="$endTime_VALUE div $Milliseconds_CONST"/>
      <xsl:attribute name="startTime">
        <xsl:value-of select="$startTime_Seconds"/>
      </xsl:attribute>
      <xsl:attribute name="endTime">
        <xsl:value-of select="$endTime_Seconds"/>
      </xsl:attribute>
      <xsl:element name="transcription">
      	<xsl:value-of select="./item[@type = 'txt']"/>
      </xsl:element>
      <xsl:element name="wordlist">
        <xsl:apply-templates select="./words/word"/>
      </xsl:element>
      <xsl:element name="translation">
      	<xsl:value-of select="./item[@type = 'gls']"/>
      </xsl:element>
      <!-- any comments in a notes field that aren't our special symbols? -->
      <xsl:for-each select="./item[@type = 'note']">
          <xsl:apply-templates select="."/>
      </xsl:for-each>
		</xsl:element>
	</xsl:template>



  <!-- get any comments tier that doesn't have our special codes -->
  <!-- this is the 'otherwise' of getting the codes -->
  <xsl:template match="item[@type = 'note']">

            <xsl:choose>
              <xsl:when test="(. = 'KH') or (. = 'LW')">
              </xsl:when>
              <xsl:when test="(. = 'EN') or (. = 'KA') or (. = 'WA')">
              </xsl:when>
              <xsl:when test=". = '*PUB'">
              </xsl:when>
              <xsl:when test=". = contains(., '.jpg')">
              </xsl:when>
              <xsl:otherwise>
                <comment>
                    <xsl:value-of select="normalize-space(.)"/>
                </comment>
              </xsl:otherwise>
            </xsl:choose>
  </xsl:template>



  <xsl:template match="word">
		<xsl:element name="word">
			<xsl:element name="text">
				<xsl:value-of select="item[@type = 'txt']"/>
				<xsl:value-of select="item[@type = 'punct']"/>
			</xsl:element>
			<xsl:element name="morphemelist">
				<xsl:apply-templates select="morphemes/morph"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="morph">
		<xsl:element name="morpheme">
			<xsl:element name="text">
				<xsl:attribute name="kind">morpheme</xsl:attribute>
				<xsl:value-of select="item[@type = 'cf']"/>
			</xsl:element>
			<xsl:element name="text">
				<xsl:attribute name="kind">gloss</xsl:attribute>
				<xsl:value-of select="item[@type = 'gls']"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>