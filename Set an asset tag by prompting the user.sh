#!/bin/bash

# Prompt user to choose site: Minneapolis, Eau Claire, London
# Prompt user for asset tag
# Validate asset tag matches MSP-####, EC-#####, or (London) ########
# If asset tag does not match requirements, continue to prompt user utnil the data is valid
# after validating, submit to Jamf Pro

validate_assetTag() {
	if [[ "$2" == "Minneapolis" ]]; then
		if ! [[ "$1" =~ ^MSP-[0-9]{4}$ ]]; then
			return 1
		else
			return 0
		fi
	elif [[ "$2" == "Eau Claire" ]]; then
		if ! [[ "$1" =~ ^EC-[0-9]{5}$ ]]; then
			return 1
		else
			return 0
		fi
	elif [[ "$2" == "London" ]]; then
		if ! [[ "$1" =~ ^[0-9]{8}$ ]]; then
			return 1
		else
			return 0
		fi
	else
		return 1
	fi
}

site=$(osascript -e 'choose from list {"Minneapolis", "Eau Claire", "London"} with prompt "Choose your location:"')

if [[ "$site" == "Minneapolis" ]]; then
	format="MSP-####"
elif [[ "$site" == "Eau Claire" ]]; then
	format="EC-#####"
else
	format="########"
fi

while true; do
	assetTag=$(osascript -e "text returned of (display dialog \"Please input your asset tag:\" default answer \"${format}\")")

	if validate_assetTag  "$assetTag" "$site"; then
		/usr/local/bin/jamf recon -assetTag "$assetTag"
		break
	fi
	
done
	