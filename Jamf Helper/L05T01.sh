#!/bin/bash

# Compose a script to do the following using jamfHelper.app
# Display a message, informing the user to update their inventory with two buttons, Cancel and Proceed
# Update inventory if the user selects "Proceed
# Show an extra message, informing the user inventory will not update if the user selects "cancel"

jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"

returnCode=$("$jamfHelper" \
	-windowType utility \
	-title "Inventory Time" \
	-description "You must update your inventory" \
	-button1 "Proceed" \
	-button2 "Cancel" \
	-defaultButton 1)

echo "$returnCode"

if [[ $returnCode -eq 0 ]]; then
	/usr/local/bin/jamf recon	
elif [[ $returnCode -eq 2 ]]; then
	"$jamfHelper" \
		-windowType utility \
		-title "Inventory Delayed" \
		-description "You chose to delay the inventory update" \
		-button1 "Whomp Whomp"
else
	echo "User closed by another method"
fi