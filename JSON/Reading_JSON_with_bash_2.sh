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

getJsonValue() {
	# $1: JSON string to parse, $2: JSON key to look up
	# $1 is passed as a command-specific environment variable so that no special
	# characters in valid JSON need to be escaped, and no code execution is
	# possible since the contents cannot be interpreted as code when retrieved
	# within JXA.
	# $2 is placed directly in the JXA code since it should not be coming from
	# user input or an arbitrary source where it could be set to intentionally
	# malicious contents.

	# data=$(curl -sS '<http-api-url>')
	# myValue=$(getJsonValue "$data" '<json-key>')
	# echo "$myValue"
	
	JSON="$1" osascript -l 'JavaScript' \
	-e 'const env = $.NSProcessInfo.processInfo.environment.objectForKey("JSON").js' \
	-e "JSON.parse(env).$2"
}

checkTokenExpiration

data=$(curl -sS -X GET "${url}api/v1/computers-inventory-detail/5" -H "accept: application/json" -H "Authorization: Bearer ${bearerToken}")
myValue=$(getJsonValue "$data" 'general.name')
echo "$myValue"

checkTokenExpiration
invalidateToken