<?xml version="1.0" encoding="UTF-8"?>

<!--
Transforms flextext xml into eopas xml
By John Mansfield, University of Melbourne, 10 August 2015
Mod Ben Foley, for Myfany Turpin's Ken Hale Kaytetye Corpus, 5 Sep 2016
-->

<!--
USAGE EXAMPLES
CLI, using Saxon:
java -jar -Xmx1024m /Library/SaxonHE9-4-0-4J/saxon9he.jar -t SOURCEPATH/SOURCE.flextext scripts/flex-to-eopas.xsl > TARGETPATH/SOURCE_eopas.xml
EOPAS:
rails runner bin/transcode.rb features/test_data/kh4560.flextext Flex
-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/">

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
				<!-- there are more potential meta elements, but not clear how to populate them-->
			</xsl:element>
			<xsl:element name="interlinear">
        <xsl:apply-templates select="interlinear-text/paragraphs/paragraph/phrases/phrase"/>
			</xsl:element>
		</eopas>
	</xsl:template>

	<xsl:template match="phrase">


    <xsl:variable name="i" select="position()" />
    <xsl:element name="phrase">

      <!-- get attributes from notes | there must be a better way to do this -->
      <xsl:analyze-string regex="(KH|LW)|(KA|WA)|(\*PUB)|([p0-9]{{4}})" select=".">
        <xsl:matching-substring>
          <xsl:choose>
            <xsl:when test="regex-group(1)">
              <xsl:attribute name="participant">
                <xsl:value-of select="."/>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="regex-group(2)">
              <xsl:attribute name="lang_code">
                <xsl:value-of select="."/>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="regex-group(3)">
              <xsl:attribute name="pub">
                <xsl:value-of select="."/>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="regex-group(4)">
              <xsl:attribute name="pdf">
                <xsl:value-of select="."/>
              </xsl:attribute>
            </xsl:when>
          </xsl:choose>
        </xsl:matching-substring>
      </xsl:analyze-string>
      <!-- phrase ID needs to be non-numeric -->
      <xsl:attribute name="id">
        <xsl:value-of select="concat('a',$i)"/>
			</xsl:attribute>
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
      <!-- any notes in notes that aren't our special symbols? -->
      <xsl:apply-templates select="./item[@type = 'note']"/>
		</xsl:element>
	</xsl:template>

  <xsl:template match="item[@type='note']">
      <xsl:analyze-string regex="(KH|LW)|(KA|WA)|(\*PUB)|(p[0-9]{{0,3}})" select=".">
        <xsl:non-matching-substring>
        <xsl:element name="comment">
            <xsl:value-of select="."/>
        </xsl:element>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
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
			<!-- These next two will have to be blocked if eopas can't handle them... though that will mean throwing away morphological information. -->
			<!--xsl:element name="text">
				<xsl:attribute name="kind">cf</xsl:attribute>
				<xsl:value-of select="item[@type = 'cf']"/>
			</xsl:element>
			<xsl:element name="text">
				<xsl:attribute name="kind">msa</xsl:attribute>
				<xsl:value-of select="item[@type = 'msa']"/>
			</xsl:element-->
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>