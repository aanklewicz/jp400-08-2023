#!/bin/bash

results=$(mdfind -count "kMDItemAppStoreCategory == 'Productivity'" -onlyin /Applications/)

echo "<results>$results</results>"
