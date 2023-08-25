#!/bin/bash

plistFile="/Library/LaunchDaemons/com.jp400.YourMom.plist"
plistLabel=$(basename $plistFile | sed 's/.plist//g')

# echo $plistLabel

scriptPath="/Users/Shared/YourMom.sh"

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

user="jamf_it"
displayMessage="no"



if [[ $(dscl . list /Users) =~ "$user" ]]
then
	echo "$user exists, continuing..."
else
	echo "$user doesn't exist, creating..."
	sysadminctl -addUser jamf_it -fullName ${user} -password 'jamf1234' -home /private/var/${user} -admin
	dscl . create /Users/${user} IsHidden 1
	echo "$user created"
	displayMessage="yes"
fi

if [[ $(dscl . -list /Users IsHidden 1 | cut -f 1 -d' ') =~ "$user" ]]
then
	echo "$user is already hidden"
else
	echo "$user is not hidden, hiding..."
	dscl . create /Users/${user} IsHidden 1
	echo "$user is now hidden"
	displayMessage="yes"
fi

if [[ $(dseditgroup -o checkmember -m ${user} admin | awk {'print $4'}) = "NOT" ]]
then
	echo "$user is not an admin, elevating"
	dseditgroup -o edit -a ${user} admin
	echo "$user is now an admin"
	displayMessage="yes"
else
	echo "$user is an admin"
fi


if [[ ${displayMessage} == "yes" ]]	
then
	jamf displayMessage -message "Please do not tamper with the jamf_it account"
fi
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
<integer>9</integer>
<key>Minute</key>
<integer>30</integer>
<key>Weekday</key>
<integer>1</integer>
</dict>
</array>
</dict>
</plist>
EOF

/usr/sbin/chown root:wheel "$plistFile"
/bin/chmod 644 "$plistFile"
/bin/chmod +x "$scriptPath"

/bin/launchctl bootstrap system "$plistFile"