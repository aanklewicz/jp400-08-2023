#!/bin/bash

results=$(mdfind kMDItemUserSharedReceivedTransport == com.apple.AirDrop)

echo "<results>$results</results>"
