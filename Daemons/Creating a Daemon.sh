#!/bin/bash

plistFile="/Library/LaunchDaemons/com.jp400.checkForChrome.plist"
plistLabel=$(basename $plistFile | sed 's/.plist//g')

# echo $plistLabel

scriptPath="/Users/Shared/chromeToDock.sh"

# If the plist already exists, bootout and delete

if [[ -f $plistFile ]]
then
	/bin/launchctl bootout system "$plistFile" 2>  /dev/null
	/bin/rm -f "$plistFile"
fi

# Output the plist to a file

tee "$plistFile" << EOL
<?xml version="1.0" encoding="UTF-8"?> 
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"> 
<plist version="1.0"> 
<dict> 
<key>Label</key> 
<string>$plistLabel</string> 
<key>ProgramArguments</key> 
<array> 
<string>/bin/bash</string> 
<string>$scriptPath</string> 
</array> 
<key>StartCalendarInterval</key> 
<dict>
<key>Hour</key>
<integer>8</integer>
<key>Minute</key>
<integer>30</integer>
<key>Weekday</key>
<integer>2</integer>
</dict>
</dict> 
</plist>
EOL

# Set permissions and load file

/usr/sbin/chown root:wheel "$plistFile"
/bin/chmod 644 "$plistFile"

/bin/launchctl bootstrap system "$plistFile"