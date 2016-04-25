<?xml version="1.0" encoding="UTF-8"?>
<!-- working with EOPAS 2.0 Schema -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:dc="http://purl.org/dc/elements/1.1/"
version="1.0">
  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
  <xsl:strip-space elements="*"/>
  <xsl:param name="mediafile" select="/ANNOTATION_DOCUMENT/HEADER/MEDIA_DESCRIPTOR/@EXTRACTED_FROM"/>
  <xsl:param name="type" select="/ANNOTATION_DOCUMENT/HEADER/MEDIA_DESCRIPTOR/@MIME_TYPE"/>
  <xsl:param name="creator" select="/ANNOTATION_DOCUMENT/@AUTHOR"/>
  <xsl:param name="language_code" select="/ANNOTATION_DOCUMENT/LOCALE/@LANGUAGE_CODE"/>
  <xsl:param name="country_code" select="/ANNOTATION_DOCUMENT/LOCALE/@COUNTRY_CODE"/>
  <xsl:param name="lang_code" select="concat($language_code, '-', $country_code)"/>
  <xsl:param name="date" select="/ANNOTATION_DOCUMENT/@DATE"/>
  <xsl:template match="/">
    <xsl:if test="not(/ANNOTATION_DOCUMENT)">
        <xsl:message terminate="yes">ERROR: Not an ELAN document</xsl:message>
    </xsl:if>
    <xsl:if test="not(/ANNOTATION_DOCUMENT/HEADER/@TIME_UNITS='milliseconds')">
        <xsl:message terminate="yes">ERROR: I only understand milliseconds as TIME_UNITS</xsl:message>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="/ANNOTATION_DOCUMENT">
    <eopas>
      <header>
        <meta>
          <!-- MIME Type -->
          <xsl:attribute name="name">dc:type</xsl:attribute>
          <xsl:attribute name="value">text/xml</xsl:attribute>
        </meta>
        <meta>
          <!-- media resource URI -->
          <xsl:attribute name="name">dc:source</xsl:attribute>
          <xsl:attribute name="value">
            <xsl:value-of select="$mediafile"/>
          </xsl:attribute>
        </meta>
        <meta>
          <!-- Dublin Core "creator" -->
          <xsl:attribute name="name">dc:creator</xsl:attribute>
          <xsl:attribute name="value">
            <xsl:value-of select="$creator"/>
          </xsl:attribute>
        </meta>
        <meta>
          <!-- language code -->
          <xsl:attribute name="name">dc:language</xsl:attribute>
          <xsl:attribute name="value">
            <xsl:value-of select="$lang_code"/>
          </xsl:attribute>
        </meta>
        <meta>
          <!-- Date -->
          <xsl:attribute name="name">dc:date</xsl:attribute>
          <xsl:attribute name="value">
            <xsl:value-of select="$date"/>
          </xsl:attribute>
        </meta>
      </header>

      <interlinear>

        <xsl:choose>

        <!-- FIRST CASE: utterance and word tiers, plus gloss and attachment -->
        <!-- write a transcription if there are utterances -->

        <xsl:when test="TIER[@TIER_ID='Phrase']">

          <!-- Get Phrases from utterances and sort them on their number -->
          <xsl:for-each select="TIER[@TIER_ID='Phrase']/ANNOTATION/ALIGNABLE_ANNOTATION">
            <xsl:sort select="substring-after(@TIME_SLOT_REF1, 'ts')" data-type="number"/>

            <!-- grab phrase timing -->
            <xsl:variable name="startTimeId" select="@TIME_SLOT_REF1"/>
            <xsl:variable name="endTimeId" select="@TIME_SLOT_REF2"/>
            <xsl:variable name="startTime_VALUE" select="/ANNOTATION_DOCUMENT/TIME_ORDER/TIME_SLOT[@TIME_SLOT_ID=$startTimeId]/@TIME_VALUE"/>
            <xsl:variable name="endTime_VALUE" select="/ANNOTATION_DOCUMENT/TIME_ORDER/TIME_SLOT[@TIME_SLOT_ID=$endTimeId]/@TIME_VALUE"/>
            <xsl:variable name="Milliseconds_CONST" select="1000"/>
            <xsl:variable name="startTime_Seconds" select="$startTime_VALUE div $Milliseconds_CONST"/>
            <xsl:variable name="endTime_Seconds" select="$endTime_VALUE div $Milliseconds_CONST"/>
            <xsl:variable name="annotationId" select="@ANNOTATION_ID"/>

            <!-- write phrase -->
            <phrase>
              <xsl:attribute name="id">
                <xsl:value-of select="@ANNOTATION_ID"/>
              </xsl:attribute>
              <xsl:attribute name="startTime">
                <xsl:value-of select="$startTime_Seconds"/>
              </xsl:attribute>
              <xsl:attribute name="endTime">
                <xsl:value-of select="$endTime_Seconds"/>
              </xsl:attribute>

              <xsl:if test="normalize-space(parent::TIER/@DPARTICIPANT) != ''">
                <xsl:attribute name="participant">
                  <xsl:value-of select="parent::TIER/@DPARTICIPANT"/>
                </xsl:attribute>
              </xsl:if>

              <transcription>
                <xsl:value-of select="ANNOTATION_VALUE"/>
              </transcription>

              <!-- Morphemes -->
              <xsl:if test="/ANNOTATION_DOCUMENT/TIER[@TIER_ID='Morph']">
                <morph>
                  <xsl:for-each select="/ANNOTATION_DOCUMENT/TIER[@TIER_ID='Morph']/ANNOTATION/REF_ANNOTATION[@ANNOTATION_REF = $annotationId]">
                    <xsl:if test="ANNOTATION_VALUE != ''">
                          <xsl:value-of select="normalize-space(ANNOTATION_VALUE)"/>
                    </xsl:if>
                  </xsl:for-each>
                </morph>
              </xsl:if>

              <!-- Gloss -->
              <xsl:if test="/ANNOTATION_DOCUMENT/TIER[@TIER_ID='Gloss']">
                <gloss>
                  <xsl:for-each select="/ANNOTATION_DOCUMENT/TIER[@TIER_ID='Gloss']/ANNOTATION/REF_ANNOTATION[@ANNOTATION_REF = $annotationId]">
                    <xsl:if test="ANNOTATION_VALUE != ''">
                          <xsl:value-of select="normalize-space(ANNOTATION_VALUE)"/>
                    </xsl:if>
                  </xsl:for-each>
                </gloss>
              </xsl:if>

              <!-- Translation -->
              <xsl:if test="/ANNOTATION_DOCUMENT/TIER[@TIER_ID='Free Translation']">
                <translation>
                  <xsl:for-each select="/ANNOTATION_DOCUMENT/TIER[@TIER_ID='Free Translation']/ANNOTATION/REF_ANNOTATION[@ANNOTATION_REF = $annotationId]">
                    <xsl:if test="ANNOTATION_VALUE != ''">
                          <xsl:value-of select="normalize-space(ANNOTATION_VALUE)"/>
                    </xsl:if>
                  </xsl:for-each>
                </translation>
              </xsl:if>

              <!-- Notes, Attachments & Images -->
              <xsl:if test="/ANNOTATION_DOCUMENT/TIER[@TIER_ID='Notes']">
                <attachment>
                  <xsl:for-each select="/ANNOTATION_DOCUMENT/TIER[@TIER_ID='Notes']/ANNOTATION/REF_ANNOTATION[@ANNOTATION_REF = $annotationId]">
                    <xsl:if test="ANNOTATION_VALUE != ''">
                          <xsl:value-of select="normalize-space(ANNOTATION_VALUE)"/>
                    </xsl:if>
                  </xsl:for-each>
                </attachment>
              </xsl:if>

            </phrase>
          </xsl:for-each>
        </xsl:when>




        <!-- DEFAULT CASE: fail -->
        <xsl:otherwise>
          <xsl:message terminate="yes">ERROR: Unsupported TIER_ID in Tier</xsl:message>
        </xsl:otherwise>

        </xsl:choose>

      </interlinear>
    </eopas>
  </xsl:template>
</xsl:stylesheet>
