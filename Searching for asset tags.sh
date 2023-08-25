#!/bin/bash

# Prompt user for an asset tag of a found mobile device

# Use the input to identify the mobile device(s) via asset tag

# If no devices are found, show a message "No matching asset tag found"

# if one device is found, show a confirmation that only one was found
# show a message with the username, building and department of device

# If multiple devices found, show how many devices were found
# Show a message with the username, building, and department of each device

# Prompt user to save the results to a file "/Users/Shared/Search Results.txt"

# Let's start by declaring the save file location, get that out of the way...

saveFile="/Users/Shared/Search Results.txt"

# Let's import the Jamf API calls as found https://developer.jamf.com/jamf-pro/docs/jamf-pro-api-overview

username="InsertUserNameHere"
password="InsertPasswordHere"
url=$(defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url)

#Variable declarations
bearerToken=""
tokenExpirationEpoch="0"

getBearerToken() {
	response=$(curl -s -u "$username":"$password" ${url}api/v1/auth/token -X POST)
	bearerToken=$(echo "$response" | plutil -extract token raw -)
	tokenExpiration=$(echo "$response" | plutil -extract expires raw - | awk -F . '{print $1}')
	tokenExpirationEpoch=$(date -j -f "%Y-%m-%dT%T" "$tokenExpiration" +"%s")
}

checkTokenExpiration() {
	nowEpochUTC=$(date -j -f "%Y-%m-%dT%T" "$(date -u +"%Y-%m-%dT%T")" +"%s")
	if [[ tokenExpirationEpoch -gt nowEpochUTC ]]
	then
		# echo "Token valid until the following epoch time: " "$tokenExpirationEpoch"
		cat="" # I have to do SOMETHING in this elif
	else
		# echo "No valid token available, getting new token"
		getBearerToken
	fi
}

invalidateToken() {
	responseCode=$(curl -w "%{http_code}" -H "Authorization: Bearer ${bearerToken}" ${url}api/v1/auth/invalidate-token -X POST -s -o /dev/null)
	if [[ ${responseCode} == 204 ]]
	then
		# echo "Token successfully invalidated"
		bearerToken=""
		tokenExpirationEpoch="0"
	elif [[ ${responseCode} == 401 ]]
	then
		# echo "Token already invalid"
		cat="" # I have to do SOMETHING in this elif
	else
		# echo "An unknown error occurred invalidating the token"
		cat="" # I have to do SOMETHING in this elif
	fi
}

exportFile ()
{
	cat > "$1" << EOF
$2
EOF
}

checkTokenExpiration

# Yum yum! Here's the meat of the script!

# Prompt user for an asset tag of a found mobile device
# Returns either "buttonreturned:Scan," or "buttonreturned:Quit,"

response=$(osascript -e "display dialog \"Please input your asset tag:\" default answer \"Enter asset tag here\" buttons {\"Quit\", \"Scan\"} default button 2")

buttonReturned=$(echo "${response}" | awk '{print $1 $2}')
assetTag=$(echo "${response}" | awk -F: '{ print $NF }')

if [[ ${buttonReturned} == "buttonreturned:Quit," ]]; then
	echo "User chose to quit, quitting..."
	exit 0
elif [[ ${buttonReturned} == "buttonreturned:Scan," ]]; then
	echo "User submitted a Scan with asset tag: ${assetTag}"
	
	# Use the input to identify the mobile device(s) via asset tag
	
	rawData=$(curl -s -H "Authorization: Bearer ${bearerToken}" "${url}JSSResource/computers/match/${assetTag}" -X GET -H "accept: application/xml")
	
	totalFoundRecords=$(echo ${rawData} | xmllint --xpath '/computers/size/text()' -)
	
	echo "Total Found Records = ${totalFoundRecords}"
	
	if [[ ${totalFoundRecords} -eq 0 ]]; then
		
		# If no devices are found, show a message "No matching asset tag found"
		
		osascript -e "display dialog \"No matching asset tag found\" buttons {\"Thank you for trying, please play again soon!\"} default button 1"

	elif [[ ${totalFoundRecords} -eq 1 ]]; then
		
		# if one device is found, show a confirmation that only one was found
		# show a message with the username, building and department of device
		
		mobileDeviceName=$(echo ${rawData} | xmllint --xpath '/computers/computer["0"]/name/text()' -)
		userName=$(echo ${rawData} | xmllint --xpath '/computers/computer["0"]/username/text()' -)
		building=$(echo ${rawData} | xmllint --xpath '/computers/computer["0"]/building/text()' -)
		department=$(echo ${rawData} | xmllint --xpath '/computers/computer["0"]/department/text()' -)
		
		buttonPressed=$(osascript -e "display dialog \"Only one item was found.\n\n${mobileDeviceName} - ${userName} - ${building} - ${department}\n\nWould you like to save?\" buttons {\"No thanks!\", \"Save\"} default button 2")
		
		if [[ ${buttonPressed} == "button returned:Save" ]]; then
			
			passedData="${mobileDeviceName} - ${userName} - ${building} - ${department}"
			
			exportFile "${saveFile}" "${passedData}"
			
		fi
		
	else
		# If multiple devices found, show how many devices were found
		# Show a message with the username, building, and department of each device
			
		count="${totalFoundRecords}"
		count=$((++count))
		passedData=()
		
		while (( --count >= 1 )); do
			echo ${count}
			mobileDeviceName=$(echo ${rawData} | xmllint --xpath "/computers/computer[$count]/name/text()" -)
			userName=$(echo ${rawData} | xmllint --xpath "/computers/computer[$count]/username/text()" -)
			building=$(echo ${rawData} | xmllint --xpath "/computers/computer[$count]/serial_number/text()" -)
			department=$(echo ${rawData} | xmllint --xpath "/computers/computer[$count]/department/text()" -)
			passedData+=("${mobileDeviceName} - ${userName} - ${building} - ${department}")
		done
		
		buttonPressed=$(osascript -e "display dialog \"Multiple (${totalFoundRecords}) items were found, would you like to save?\n\n${passedData}\" buttons {\"No thanks!\", \"Save\"} default button 2")
		
		if [[ ${buttonPressed} == "button returned:Save" ]]; then
			
			exportFile "${saveFile}" "${passedData}"
			
		fi
	fi
else
	echo "Something went wrong, quitting..."
	exit 0
fi

# curl -s -H "Authorization: Bearer ${bearerToken}" ${url}JSSResource/mobiledevices/id/93 -X GET -H "accept: application/xml" | xmllint --format -

# Let's finish the script by killing the bearer token

checkTokenExpiration
invalidateToken