#!/bin/bash

#Compose a script to do the floowing:
# Show a message informing the user to input a phone number and store the input as a variable.
# Update the phone number in Jamf Pro using the Jamf binary

# Function to display a dialog
display_dialog() {
	osascript -e "display dialog \"$1\" buttons {\"OK\"} default button \"OK\""
}

# Validate North American phone number using grep
validate_phone_number() {
	if ! [[ "$1" =~ ^[0-9]{3}-[0-9]{3}-[0-9]{4}$ ]]; then
		return 1
	fi
	return 0
}

# Loop until a valid phone number is entered
while true; do
	# Display a message to input a phone number
	phoneNumber=$(osascript -e 'text returned of (display dialog "Please input your phone number:" default answer "XXX-XXX-XXXX")')
	
	# Validate the inputted phone number
	if validate_phone_number "$phoneNumber"; then
		break
	else
		display_dialog "Invalid phone number format. Please enter a valid North American phone number."
	fi
done

/usr/local/bin/jamf recon -phone "$phoneNumber"