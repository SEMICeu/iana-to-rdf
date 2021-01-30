<?php

  $xmluri = $argv[1];
  $dir    = $argv[2];
  $ext    = $argv[3];

//  $xmluri = 'https://www.iana.org/assignments/media-types/media-types.xml';
//  $xsluri = '../../iana-registry-to-rdf/iana-registry-to-rdf.xsl';
  $xsluri = '../iana-to-rdf.xsl';

  $targetfilepath = './' . $dir . '/' . basename($xmluri, '.xml') . '.' . $ext;

  $xml = new DOMDocument;
  $xml->load($xmluri); 

  $xsl = new DOMDocument;
  $xsl->load($xsluri);

  $proc = new XSLTProcessor();
  $proc->importStyleSheet($xsl);

  $rdf = $proc->transformToXML($xml);

//  header('Content-type: application/xml');
//  echo $rdf;

  file_put_contents($targetfilepath, $rdf);

?>
