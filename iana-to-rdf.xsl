<?xml version="1.0" encoding="UTF-8"?>

<!--

  Copyright 2017-2021 EUROPEAN UNION
  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by
  the European Commission - subsequent versions of the EUPL (the "Licence");
  You may not use this work except in compliance with the Licence.
  You may obtain a copy of the Licence at:

  https://joinup.ec.europa.eu/collection/eupl

  Unless required by applicable law or agreed to in writing, software
  distributed under the Licence is distributed on an "AS IS" basis,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the Licence for the specific language governing permissions and
  limitations under the Licence.

  Authors:      European Commission, Joint Research Centre (JRC)
                Andrea Perego (https://github.com/andrea-perego)

  Source code:  https://github.com/SEMICeu/iana-to-rdf

-->

<!--

  PURPOSE AND USAGE

  This XSLT is a proof of concept for the RDF representation of the IANA
  registry.

  As such, this XSLT must be considered as unstable.

-->

<xsl:transform

    xmlns:adms   = "http://www.w3.org/ns/adms#"
    xmlns:dc     = "http://purl.org/dc/elements/1.1/"
    xmlns:dcat   = "http://www.w3.org/ns/dcat#"
    xmlns:dct    = "http://purl.org/dc/terms/"
    xmlns:foaf   = "http://xmlns.com/foaf/0.1/"
    xmlns:owl    = "http://www.w3.org/2002/07/owl#"
    xmlns:rdf    = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs   = "http://www.w3.org/2000/01/rdf-schema#"
    xmlns:skos   = "http://www.w3.org/2004/02/skos/core#"
    xmlns:xsd    = "http://www.w3.org/2001/XMLSchema#"
    
    xmlns:iana   = "http://www.iana.org/assignments"
    xmlns:xlink  = "http://www.w3.org/1999/xlink"
    xmlns:xsi    = "http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl    = "http://www.w3.org/1999/XSL/Transform"
    
    exclude-result-prefixes="iana xlink xsi xsl"
    version="1.0"

>

  <xsl:output 
    method="xml"
    indent="yes"
    encoding="utf-8" />

<!--

  Global variables
  ================

-->

<!-- Variables $core and $extended. -->
<!--

  These variables are meant to be placeholders for the IDs used for the core and extended profiles of GeoDCAT-AP.

-->

  <xsl:param name="iana-registry-uri">https://www.iana.org/assignments</xsl:param>


<!-- Variables to be used to convert strings into lower/uppercase by using the translate() function. -->

  <xsl:variable name="lowercase">abcdefghijklmnopqrstuvwxyz</xsl:variable>
  <xsl:variable name="uppercase">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

<!-- Namespaces -->

  <xsl:param name="xsd">http://www.w3.org/2001/XMLSchema#</xsl:param>
  <xsl:param name="dct">http://purl.org/dc/terms/</xsl:param>
  <xsl:param name="skos">http://www.w3.org/2004/02/skos/core#</xsl:param>
  <xsl:param name="dcat">http://www.w3.org/ns/dcat#</xsl:param>
  <xsl:param name="op">http://publications.europa.eu/resource/authority/</xsl:param>
  <xsl:param name="opcb" select="concat($op,'corporate-body/')"/>
  <xsl:param name="opcs" select="concat($op,'concept-status/')"/>
  <xsl:param name="opcountry" select="concat($op,'country/')"/>
  <xsl:param name="opfq" select="concat($op,'frequency/')"/>
  <xsl:param name="oplang" select="concat($op,'language/')"/>
  <xsl:param name="cldFrequency">http://purl.org/cld/freq/</xsl:param>

<!--

  Master template
  ===============

 -->

  <xsl:template match="/">
    <rdf:RDF>
      <xsl:apply-templates select="iana:registry">
        <xsl:with-param name="base-uri" select="$iana-registry-uri"/>
      </xsl:apply-templates>
    </rdf:RDF>
  </xsl:template>

<!-- Register -->

  <xsl:template match="iana:registry">
    <xsl:param name="base-uri"/>
    <xsl:param name="id" select="normalize-space(@id)"/>
    <xsl:param name="uri" select="concat($base-uri, '/', $id)"/>
    <xsl:param name="title" select="normalize-space(iana:title)"/>
    <xsl:param name="category" select="normalize-space(iana:category)"/>
    <xsl:param name="updated" select="normalize-space(iana:updated)"/>
    <xsl:param name="registration_rule" select="iana:registration_rule"/>
    <xsl:param name="expert" select="normalize-space(iana:expert)"/>
    <rdf:Description rdf:about="{$uri}">
      <rdf:type rdf:resource="{$skos}ConceptScheme"/>
      <rdf:type rdf:resource="{$dcat}Dataset"/>
      <dct:identifier rdf:datatype="{$xsd}string"><xsl:value-of select="$id"/></dct:identifier>
      <skos:prefLabel xml:lang="en"><xsl:value-of select="$title"/></skos:prefLabel>
      <rdfs:label xml:lang="en"><xsl:value-of select="$title"/></rdfs:label>
      <dct:title xml:lang="en"><xsl:value-of select="$title"/></dct:title>
      <xsl:if test="$category != ''">
        <dc:subject><xsl:value-of select="$category"/></dc:subject>
      </xsl:if>
      <xsl:if test="$expert != ''">
        <dc:creator><xsl:value-of select="$expert"/></dc:creator>
      </xsl:if>
      <xsl:if test="$updated != ''">
        <dct:modified rdf:datatype="{$xsd}date"><xsl:value-of select="$updated"/></dct:modified>
      </xsl:if>
      <dct:source rdf:resource="{$iana-registry-uri}"/>
      <dct:publisher rdf:resource="https://www.iana.org/"/>
      <xsl:for-each select="iana:registry">
        <dct:hasPart rdf:resource="{$uri}/{@id}"/>
      </xsl:for-each>
      <xsl:if test="$base-uri != $iana-registry-uri">
        <dct:isPartOf rdf:resource="{$base-uri}"/>
      </xsl:if>
      <xsl:for-each select="iana:registry/iana:record">
        <xsl:variable name="record-uri1">
          <xsl:choose>
            <xsl:when test="iana:file[@type = 'template']">
              <xsl:value-of select="concat($uri, '/', normalize-space(iana:file[@type = 'template']))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="normalize-space(iana:name) != '' and contains(normalize-space(iana:name), ' ')">
                  <xsl:value-of select="concat($uri, '/', ../@id, '/', substring-before(normalize-space(iana:name), ' '))"/>
                </xsl:when>
                <xsl:when test="normalize-space(iana:name) != '' and not(contains(normalize-space(iana:name), ' '))">
                  <xsl:value-of select="concat($uri, '/', ../@id, '/', normalize-space(iana:name))"/>
                </xsl:when>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
<!--        
        <skos:hasTopConcept rdf:resource="{$uri}/{../@id}/{iana:name}"/>
-->        
        <skos:hasTopConcept rdf:resource="{$record-uri1}"/>
      </xsl:for-each>
      <xsl:for-each select="iana:record">
        <xsl:variable name="record-uri2">
          <xsl:choose>
            <xsl:when test="iana:file[@type = 'template']">
              <xsl:value-of select="concat($uri, '/', substring-after(normalize-space(iana:file[@type = 'template']),'/'))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="normalize-space(iana:name) != '' and contains(normalize-space(iana:name), ' ')">
                  <xsl:value-of select="concat($uri, '/', substring-before(normalize-space(iana:name), ' '))"/>
                </xsl:when>
                <xsl:when test="normalize-space(iana:name) != '' and not(contains(normalize-space(iana:name), ' '))">
                  <xsl:value-of select="concat($uri, '/', normalize-space(iana:name))"/>
                </xsl:when>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
<!--        
        <skos:hasTopConcept rdf:resource="{$uri}/{iana:name}"/>
-->        
        <skos:hasTopConcept rdf:resource="{$record-uri2}"/>
      </xsl:for-each>
    </rdf:Description>
    <xsl:apply-templates select="iana:registry">
      <xsl:with-param name="base-uri" select="$uri"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="iana:record">
      <xsl:with-param name="base-uri" select="$uri"/>
      <xsl:with-param name="parent-uri" select="$base-uri"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="iana:people/iana:person">
      <xsl:with-param name="base-uri" select="$uri"/>
    </xsl:apply-templates>
  </xsl:template>

<!-- Record -->

  <xsl:template match="iana:record">
    <xsl:param name="base-uri"/>
    <xsl:param name="parent-uri"/>
    <xsl:param name="date" select="normalize-space(@date)"/>
    <xsl:param name="name" select="normalize-space(iana:name)"/>
    <xsl:param name="obsolete">
      <xsl:if test="contains(translate($name, $uppercase, $lowercase),'obsolete')">
        <owl:deprecated>true</owl:deprecated>
        <adms:status rdf:resource="{$opcs}DEPRECATED"/>
      </xsl:if>
    </xsl:param>
    <xsl:param name="deprecated">
      <xsl:if test="contains(translate($name, $uppercase, $lowercase),'deprecated')">
        <owl:deprecated>true</owl:deprecated>
        <adms:status rdf:resource="{$opcs}DEPRECATED"/>
      </xsl:if>
    </xsl:param>
    <xsl:param name="replaced-by">
      <xsl:if test="contains(translate($name, $uppercase, $lowercase),'in favor of')">
        <xsl:variable name="replacement" select="translate(normalize-space(substring-after(translate($name, $uppercase, $lowercase),'in favor of')),'()','')"/>
        <xsl:if test="$replacement != '' and contains($replacement, '/')">
          <dct:isReplacedBy rdf:resource="{$base-uri}/{substring-after($replacement, '/')}"/>
        </xsl:if>
      </xsl:if>
    </xsl:param>
    <xsl:param name="file-template" select="normalize-space(iana:file[@type = 'template'])"/>
<!--    
    <xsl:param name="uri">
      <xsl:choose>
        <xsl:when test="$file-template != ''">
          <xsl:value-of select="concat($base-uri, '/', substring-after($file-template,'/'))"/>
        </xsl:when>
      </xsl:choose>
    </xsl:param>
-->    
    <xsl:param name="uri">
      <xsl:choose>
        <xsl:when test="$file-template">
          <xsl:value-of select="concat($base-uri, '/', substring-after($file-template,'/'))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$name != '' and contains(normalize-space($name), ' ')">
              <xsl:value-of select="concat($base-uri, '/', substring-before($name, ' '))"/>
            </xsl:when>
            <xsl:when test="$name != '' and not(contains($name, ' '))">
              <xsl:value-of select="concat($base-uri, '/', $name)"/>
            </xsl:when>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="record">
      <rdf:type rdf:resource="{$skos}Concept"/>
      <rdf:type rdf:resource="{$dct}Standard"/>
      <xsl:if test="starts-with($uri, concat($iana-registry-uri, '/', 'media-types'))">
        <rdf:type rdf:resource="{$dct}MediaType"/>
      </xsl:if>
      <dct:identifier rdf:datatype="{$dct}IMT"><xsl:value-of select="substring-after($uri, concat($parent-uri,'/'))"/></dct:identifier>
      <xsl:if test="$parent-uri != ''">
        <skos:inScheme rdf:resource="{$parent-uri}"/>
      </xsl:if>
      <xsl:if test="$base-uri != ''">
        <skos:inScheme rdf:resource="{$base-uri}"/>
      </xsl:if>
      <xsl:if test="$parent-uri != ''">
        <skos:topConceptOf rdf:resource="{$parent-uri}"/>
      </xsl:if>
      <xsl:if test="$base-uri != ''">
        <skos:topConceptOf rdf:resource="{$base-uri}"/>
      </xsl:if>
      <xsl:if test="starts-with($uri, concat($iana-registry-uri, '/', 'media-types')) and $file-template != ''">
        <skos:notation rdf:datatype="{$dct}IMT"><xsl:value-of select="$file-template"/></skos:notation>
      </xsl:if>
      <skos:prefLabel xml:lang="en"><xsl:value-of select="$name"/></skos:prefLabel>
      <rdfs:label xml:lang="en"><xsl:value-of select="$name"/></rdfs:label>
      <dct:title xml:lang="en"><xsl:value-of select="$name"/></dct:title>
      <xsl:if test="$date != ''">
        <dct:date rdf:datatype="{$xsd}date"><xsl:value-of select="$date"/></dct:date>
      </xsl:if>
      <xsl:copy-of select="$obsolete"/>
      <xsl:copy-of select="$deprecated"/>
      <xsl:copy-of select="$replaced-by"/>
      <xsl:apply-templates select="iana:xref">
        <xsl:with-param name="context">record</xsl:with-param>
      </xsl:apply-templates>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="$uri != ''">
        <rdf:Description rdf:about="{$uri}">
          <xsl:copy-of select="$record"/>
        </rdf:Description>
      </xsl:when>
      <xsl:otherwise>
        <rdf:Description>
          <xsl:copy-of select="$record"/>
        </rdf:Description>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!-- Reference -->

  <xsl:template match="iana:xref">
    <xsl:param name="context"/>
    <xsl:choose>
      <xsl:when test="@type = 'rfc'">
        <xsl:choose>
          <xsl:when test="$context = 'text'">
            <xsl:value-of select="concat('[',translate(@data,$lowercase,$uppercase),']')"/>
          </xsl:when>
          <xsl:when test="$context = 'registry'">
            <dct:conformsTo rdf:resource="https://tools.ietf.org/html/{@data}"/>
          </xsl:when>
          <xsl:when test="$context = 'record'">
            <rdfs:isDefinedBy rdf:resource="https://tools.ietf.org/html/{@data}"/>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="@type = 'person'">
        <xsl:choose>
          <xsl:when test="$context = 'text'">
            <xsl:value-of select="concat('[',@data,']')"/>
          </xsl:when>
          <xsl:when test="$context = 'registry'">
            <dct:contributor rdf:nodeID="b{@data}"/>
          </xsl:when>
          <xsl:when test="$context = 'record'">
            <dct:contributor rdf:nodeID="b{@data}"/>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
<!--  
  <xsl:template name="tokenizeRefs">
    <xsl:param name="list"/>
    <xsl:param name="delimiter"/>
    <xsl:param name="base-uri"/>
    <xsl:choose>
      <xsl:when test="contains($list, $delimiter)">
        <dct:replacedBy rdf:resource="{normalize-space(substring-before($list,$delimiter))}"/>
        <xsl:call-template name="tokenizeKeywords">
          <xsl:with-param name="list" select="substring-after($list,$delimiter)"/>
          <xsl:with-param name="delimiter" select="$delimiter"/>
          <xsl:with-param name="base-uri" select="$base-uri"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="normalize-space($list) = ''">
            <xsl:text/>
          </xsl:when>
          <xsl:otherwise>
            <dct:replacedBy rdf:resource="{normalize-space($list)}"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
-->  

<!-- Person -->

  <xsl:template match="iana:people/iana:person">
    <xsl:param name="id" select="normalize-space(@id)"/>
    <xsl:param name="name" select="normalize-space(iana:name)"/>
    <xsl:param name="uri" select="normalize-space(iana:uri)"/>
    <xsl:param name="updated" select="normalize-space(iana:updated)"/>
    <foaf:Agent rdf:nodeID="b{$id}">
      <xsl:if test="$name != ''">
        <foaf:name><xsl:value-of select="$name"/></foaf:name>
      </xsl:if>
      <xsl:if test="$uri != ''">
        <xsl:choose>
<!--
          <xsl:when test="starts-with($uri, 'mailto:')">
            <foaf:mbox rdf:resource="{$uri}"/>
          </xsl:when>
-->
          <xsl:when test="starts-with($uri, 'http')">
            <foaf:homepage rdf:resource="{$uri}"/>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
      <xsl:if test="$updated != ''">
        <dct:modified rdf:datatype="{$xsd}date"><xsl:value-of select="$updated"/></dct:modified>
      </xsl:if>
    </foaf:Agent>
  </xsl:template>

</xsl:transform>
