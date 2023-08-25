#!/bin/bash

plistFile="/Library/LaunchDaemons/com.jp400.L03T04.plist"
plistLabel=$(basename $plistFile | sed 's/.plist//g')

scriptPath="/Users/Shared/chromeToDock.sh"

if [[ -f $plistFile ]]
then
	/bin/launchctl bootout system "$plistFile" 2>  /dev/null
	/bin/rm -f "$plistFile"
fi

if [[ -f $scriptPath ]]
then
	/bin/rm -f "$scriptPath"
fi

tee $scriptPath << EOF
#!/bin/bash

if [[ -d /Applications/FSMonitor.app/ ]]
then
	# /usr/local/jamf/bin/jamf policy -trigger chromeDock
	echo "FSMonitor already installed"
	exit 0
else
	/usr/local/jamf/bin/jamf policy -trigger InstallFSMonitor
	echo "FSMonitor has been installed"
	exit 0
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
<integer>12</integer>
<key>Minute</key>
<integer>0</integer>
<key>Weekday</key>
<integer>1</integer>
</dict>
</array>
</dict>
</plist>
EOF

/usr/sbin/chown root:wheel "$plistFile"
/usr/sbin/chown root:wheel "$scriptPath"
/bin/chmod 644 "$plistFile"
/bin/chmod +x "$scriptPath"

/bin/launchctl bootstrap system "$plistFile"