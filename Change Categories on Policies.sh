#!/bin/bash

plistFile="/Library/LaunchDaemons/com.jp400.HeyLoser.plist"
plistLabel=$(basename $plistFile | sed 's/.plist//g')

# echo $plistLabel

scriptPath="/Users/Shared/HeyLoser.sh"

if [[ -f ${scriptPath} ]]
then
	/bin/rm -f "$scriptPath" 2>  /dev/null
fi

if [[ -f $plistFile ]]
then
	/bin/launchctl bootout system "$plistFile" 2>  /dev/null
	/bin/rm -f "$plistFile"
fi

tee $scriptPath << "EOF"
#!/bin/bash

# Compose a script to do the following
# Identify any policies that are not enabled
# Assign policies that are not enabled to a category named Disabled Policies (Disabled policies can be created via GUI)
# Identify any enabled policies that have a scope of "All Computers"
# Assign any enabled policies that have a scope of "All Computers" to a category named "Global Policies"
# The script should automatically execute every Friday at 21:15

username="InsertUserNameHere"
password="InsertPasswordHere"
url=$(defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url)

disabledPolicies="5"
globalPolicies="6"

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
		sleep .1 # Need something in here for the then and I want to quiet the output.
		# echo "Token valid until the following epoch time: " "$tokenExpirationEpoch"
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
		echo "Token already invalid"
	else
		echo "An unknown error occurred invalidating the token"
	fi
}

checkTokenExpiration

listOfPolicies=$(curl -s -H "Authorization: Bearer ${bearerToken}" ${url}JSSResource/policies -X GET -H "accept: application/xml")

listOfPolicyIDs=$(echo $listOfPolicies | xmllint --format - | awk -F'[<>]' '/<\/id>/{print $3}')

for policyID in $listOfPolicyIDs
do
	cachedPolicyRecord=$(curl -s -H "Authorization: Bearer ${bearerToken}" ${url}JSSResource/policies/id/${policyID} -X GET -H "accept: application/xml")
	enabledOrDisabled=$(echo ${cachedPolicyRecord} | xmllint --xpath '/policy/general/enabled/text()' -)
	scopeToAllComputers=$(echo ${cachedPolicyRecord} | xmllint --xpath '/policy/scope/all_computers/text()' -)
	if [[ $enabledOrDisabled == "false" ]]; then
		curl -s -H "Authorization: Bearer ${bearerToken}" ${url}JSSResource/policies/id/${policyID} -X PUT -H "content-type: application/xml" -d "<policy><general><category><id>${disabledPolicies}</id></category></general></policy>"
		echo "Policy ${policyID} has been moved to Disabled Policies"
	elif [[ $scopeToAllComputers == true ]]; then
		curl -s -H "Authorization: Bearer ${bearerToken}" ${url}JSSResource/policies/id/${policyID} -X PUT -H "content-type: application/xml" -d "<policy><general><category><id>${globalPolicies}</id></category></general></policy>"
		echo "Policy ${policyID} has been moved to Global Policies"
	fi
done

checkTokenExpiration
invalidateToken
EOF

tee "$plistFile" << EOF
<?xml version="1.0" encoding="UTF-8"?> 
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"> 
<plist version="1.0"> 
<dict> 
<key>Label</key> 
<string>$plistLabel</string> 
<key>ProgramArguments</key>
<array>
<string>bash</string>
<string>$scriptPath</string>
</array>
<key>StartCalendarInterval</key>
<array>
<dict>
<key>Hour</key>
<integer>21</integer>
<key>Minute</key>
<integer>15</integer>
<key>Weekday</key>
<integer>5</integer>
</dict>
</array>
</dict>
</plist>
EOF

/usr/sbin/chown root:wheel "$plistFile"
/bin/chmod 644 "$plistFile"
/bin/chmod +x "$scriptPath"

/bin/launchctl bootstrap system "$plistFile"