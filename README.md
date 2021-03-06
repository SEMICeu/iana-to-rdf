# Purpose and usage

This XSLT is a proof of concept for the RDF representation of the [IANA registry](https://www.iana.org/assignments), generated from its XML distributions.

As such, this XSLT must be considered as unstable, and can be updated any time.

Comments and inquiries should be sent via the [issue tracker](https://github.com/SEMICeu/iana-to-rdf/issues).

NB: This XSLT has been mainly tested on the [IANA Media Types register](https://www.iana.org/assignments/media-types/). If used on other IANA registers, it may require to be extended / revised.

# Content

* [`assignments/`](./assignments/): This folder contains the RDF representation of IANA registers, generated by the XSLT via the scripts in folder [`scripts/`](./scripts/).
* [`iana-to-rdf.xsl`](./iana-to-rdf.xsl): The code of the XSLT.
* [`LICENCE.md`](./LICENCE.md): The XSLT's licence.
* [`README.md`](./README.md): This document.
* [`scripts/`](./scripts/): This folder contains the scripts to run the XSLT and generate a local copy of the relevant IANA register.

#  Credits
  
This work is the result of an exercise carried out by Unit B.6 of the <a href="https://ec.europa.eu/jrc/">Joint Research Centre of the European Commission</a>.
