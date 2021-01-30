# Content

- [`transform.php`](./transform.php): Script to run the XSLT.
- [`update-media-types.sh`](./update-media-types.sh): Script to create/update the RDF representation of the [IANA Media Types register](https://www.iana.org/assignments/media-types/).

## How to run the scripts

This folder includes the scripts to:
1. Fetch the XML distribution of the IANA register of interest.
2. Run the XSLT to generate its RDF/XML representation.
3. Generate the additional RDF serialisations.

This procedure is run by a shell script - one for each of the IANA registers - which also invokes the script ([`transform.php`](./transform.php)) in charge of running the XSLT.

For instance, in order to create/update the RDF representation of the [IANA Media Types register][https://www.iana.org/assignments/media-types/], you have to run this command:

````shell
bash update-media-types.sh
````
