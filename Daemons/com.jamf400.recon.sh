#!/bin/bash

plistFile="/Library/LaunchDaemons/com.jp400.recon.plist"
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
<string>recon</string> 
</array> 
<key>RunAtLoad</key> 
<true/>
</dict> 
</plist>
EOF

/usr/sbin/chown root:wheel "$plistFile"
/bin/chmod 644 "$plistFile"

/bin/launchctl bootstrap system "$plistFile"