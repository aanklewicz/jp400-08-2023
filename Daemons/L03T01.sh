#!/bin/bash

plistFile="/Library/LaunchDaemons/com.jp400.manage.plist"
plistLabel=$(basename $plistFile | sed 's/.plist//g')

if [[ -f $plistFile ]]
then
	/bin/launchctl bootout system "$plistFile" 2>  /dev/null
	/bin/rm -f "$plistFile"
fi

tee "$plistFile" << EOF
<?xml version="1.0" encoding="UTF-8"?> 
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"> 
<plist version="1.0"> 
<dict> 
<key>Label</key> 
<string>$plistLabel</string> 
<key>ProgramArguments</key> 
<array> 
<string>/usr/local/bin/jamf</string> 
<string>manage</string> 
</array> 
<key>StartCalendarInterval</key>
<array>
<dict>
<key>Hour</key>
<integer>20</integer>
<key>Minute</key>
<integer>35</integer>
<key>Weekday</key>
<integer>2</integer>
</dict>
<dict>
<key>Hour</key>
<integer>20</integer>
<key>Minute</key>
<integer>35</integer>
<key>Weekday</key>
<integer>3</integer>
</dict>
</array>
</dict> 
</plist>
EOF

/usr/sbin/chown root:wheel "$plistFile"
/bin/chmod 644 "$plistFile"

/bin/launchctl bootstrap system "$plistFile"