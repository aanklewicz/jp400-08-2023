#!/bin/bash

# Using the Jamf Classic API
# Using xmllint on Florence's MacBook Pro (id 5)
## Print number of apps installed
## Print Asset tag
# Using XSLT
## print computer name and every app


#!/bin/bash

username="JamfUserNameHere"
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

numberOfSoftwareTitles=$(curl -s -H "Authorization: Bearer ${bearerToken}" ${url}JSSResource/computers/id/5 -X GET -H "accept: application/xml" | xmllint --xpath '/computer/software/applications/size/text()' -)
assetTag=$(curl -s -H "Authorization: Bearer ${bearerToken}" ${url}JSSResource/computers/id/5 -X GET -H "accept: application/xml" | xmllint --xpath '/computer/general/asset_tag/text()' -)

echo "Computer ID's asset tag is ${assetTag}. It has ${numberOfSoftwareTitles} applications installed."



#######################################
# Create an XSLT file at /tmp/stylesheet.xslt
#######################################
cat << EOF > /tmp/stylesheet.xslt
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text"/>
<xsl:template match="/computer">
	<xsl:text>Name: </xsl:text>
	<xsl:value-of select="general/name"/>
	<xsl:text>&#xa;</xsl:text>
<xsl:for-each select="software/applications/application">
	<xsl:value-of select="name"/>
	<xsl:text>&#xa;</xsl:text>
</xsl:for-each>
</xsl:template>
</xsl:stylesheet>
EOF

curl -s "${url}JSSResource/computers/id/5" -H "Authorization: Bearer ${bearerToken}" | xsltproc /tmp/stylesheet.xslt -

checkTokenExpiration
invalidateToken