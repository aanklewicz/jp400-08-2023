#!/bin/bash

jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"

returnCode=$("$jamfHelper" \
	-windowType utility \
	-title "Your mom!" \
	-description "Click OK to begin Installation" \
	-button1 "OK" \
	-button2 "cancel" \
	-defaultButton 1 \
	-showDelayOptions "0, 10, 20, 30")

echo "$returnCode"

button=${returnCode: -1}

echo "$button"

timer=${returnCode%?}

echo "$timer"

#if [[ $button -eq 1 ]]
#then
#	echo "The user said to do it in $timer seconds"
#	sleep "$timer"
#	echo "Do the thing"
#fi

if [[ $button -eq 1 ]]
then
	echo "<key>StartInterval</key>
		<integer>$timer</integer>"
fi