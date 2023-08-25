#!/bin/bash

username="UserNameHere"
password="PasswordHere"
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
		echo "Token valid until the following epoch time: " "$tokenExpirationEpoch"
	else
		echo "No valid token available, getting new token"
		getBearerToken
	fi
}

invalidateToken() {
	responseCode=$(curl -w "%{http_code}" -H "Authorization: Bearer ${bearerToken}" ${url}api/v1/auth/invalidate-token -X POST -s -o /dev/null)
	if [[ ${responseCode} == 204 ]]
	then
		echo "Token successfully invalidated"
		bearerToken=""
		tokenExpirationEpoch="0"
	elif [[ ${responseCode} == 401 ]]
	then
		echo "Token already invalid"
	else
		echo "An unknown error occurred invalidating the token"
	fi
}

checkTokenExpiration

listOfComputerIDs=$(curl -s -H "Authorization: Bearer ${bearerToken}" ${url}JSSResource/computers -X GET -H "accept: application/xml" | xmllint --format - | awk -F'[<>]' '/<\/id>/{print $3}')

# echo "$listOfComputerIDs"

for computerID in $listOfComputerIDs
do
	compName=$(curl -s -H "Authorization: Bearer ${bearerToken}" ${url}JSSResource/computers/id/${computerID} -X GET -H "accept: application/xml" | xmllint --xpath '/computer/general/name/text()' -)
	compSerial=$(curl -s -H "Authorization: Bearer ${bearerToken}" ${url}JSSResource/computers/id/${computerID} -X GET -H "accept: application/xml" | xmllint --xpath '/computer/general/serial_number/text()' -)
	compBuilding=$(curl -s -H "Authorization: Bearer ${bearerToken}" ${url}JSSResource/computers/id/${computerID} -X GET -H "accept: application/xml" | xmllint --xpath '/computer/location/building/text()' - 2>/dev/null)
	
	echo "$compName (ID: $computerID, Serial Number: $compSerial) is in $compBuilding"
done



checkTokenExpiration
invalidateToken