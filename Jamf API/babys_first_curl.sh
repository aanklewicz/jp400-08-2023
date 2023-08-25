#!/bin/bash

username="UserNameHere"
password="PasswordHere"
jamfProURL="JamfURLHere" # must not contain https:// or trailing slash /

authToken=$(curl -su ${username}:${password} https://${jamfProURL}/api/v1/auth/token -X POST)

api_token=$( /usr/bin/plutil -extract token raw - <<< "$authToken" )

curl -X GET -s "https://${jamfProURL}/JSSResource/computers" -H "accept: application/xml" -H "Authorization: Bearer ${api_token}" | xmllint --format -