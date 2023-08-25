#!/usr/bin/env python3

# Remember to download the python tools in Terminal by typing python3
# With python, we need to tell it that we are importing JSON
# Things that are functions will have parenthesis around them - means an array

import json
with open('/Users/admin/Desktop/flo.json') as json_data:
	# The colon is how you end a line
	# Loading this data as a variable named flo
	flo = json.load(json_data)
	print(flo['id'])
	print(flo['general']['name'])