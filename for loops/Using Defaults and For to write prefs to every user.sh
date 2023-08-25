#!/bin/bash

listOfUsers=$(dscl . -list /Users Password | awk '$2=="********"{print $1}')

for user in $listOfUsers; do
	
	homeDirectory=$(dscl . -read /Users/${user} NFSHomeDirectory | awk '{print $2}')
	
	if ! [[ ${user} == "_mbsetupuser" ]]; then
		defaults write "${homeDirectory}/Library/Preferences/com.jamfsoftware.jss.plist" allowInvalidCertificate -boolean false
		defaults write "${homeDirectory}/Library/Preferences/com.jamfsoftware.jss.plist" url -string "https://JAMF_PRO_URL/"
		
		chown "${user}:staff" "${homeDirectory}/Library/Preferences/com.jamfsoftware.jss.plist"

	fi
done

defaults write "/Library/User Template/Non_localized/Library/Preferences/com.jamfsoftware.jss.plist" allowInvalidCertificate -boolean false
defaults write "/Library/User Template/Non_localized/Library/Preferences/com.jamfsoftware.jss.plist" url -string "https://JAMF_PRO_URL/"

