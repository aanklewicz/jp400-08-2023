#!/bin/bash

results=$(mdfind -count "kMDItemAppStoreCategory == 'Games'" -onlyin /Applications/)

echo "<results>$results</results>"
