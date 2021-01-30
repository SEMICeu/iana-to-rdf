#!/bin/bash

#SDIR="xml"
#TDIR="rdf"
SDIR="../assignments/media-types"
TDIR="../assignments/media-types"

SEXT="xml"
TEXT="rdf"

echo "1. Cleaning the source folder ./$SDIR/"

rm -rf ./$SDIR/*.$SEXT

echo "2. Updating the source folder ./$SDIR/"

#cd ./$SDIR/
wget -O ./$SDIR/media-types.xml -N https://www.iana.org/assignments/media-types/media-types.xml

#cd ../scripts/

echo "3. Cleaning the target main folder ./$TDIR/"

#rm -rf ./$TDIR/*

echo

echo "3. Transforming source files and archiving the output in the target folder ./$TDIR/"
echo

for file in ./$SDIR/*.$SEXT
do
  echo "Processing: $file"
  echo `php transform.php "$file" "$TDIR" "$TEXT"`
  echo
done

for file in ./$TDIR/*.$TEXT
do
  rdfpipe -o text/turtle "$file" > "./$TDIR/$(basename "$file" ."$TEXT").ttl"
  rdfpipe -o application/ld+json "$file" > "./$TDIR/$(basename "$file" .$TEXT).jsonld"
done
sed -i $'s/    /  /g' ./$TDIR/*.ttl
sed -i $'s/    /  /g' ./$TDIR/*.jsonld

