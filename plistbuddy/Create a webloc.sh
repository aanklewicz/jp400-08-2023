#!/bin/bash

PlistBuddy="/usr/libexec/PlistBuddy"

# ${PlistBuddy} -c "Add URL string https://developer.apple.com" ~/Desktop/JamfDeveloperPage.webloc

# ${PlistBuddy} -c "Set URL https://developer.jamf.com" ~/Desktop/JamfDeveloperPage.webloc

${PlistBuddy} -c "Print" ~/Desktop/JamfDeveloperPage.webloc