#!/bin/bash

scriptPath="/Users/Shared/chromeToDock.sh"

if [[ -f "$scriptPath" ]]
then
	/bin/rm "$scriptPath"
fi

tee "$scriptPath" << EOF
#!/bin/bash

if [[ -d /Applications/Google\ Chrome.app ]]
then
	/usr/local/jamf/bin/jamf policy -trigger chromeDock
fi
EOF

/bin/chmod +x "$scriptPath"

