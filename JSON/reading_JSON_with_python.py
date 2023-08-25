#!/usr/bin/env python3

# Remember to download the python tools in Terminal by typing python3
# With python, we need to tell it that we are importing JSON
# Things that are functions will have parenthesis around them - means an array

import json
with open('/Users/admin/Desktop/all_departments.json') as json_data:
	# The colon is how you end a line
	# Loading this data as a variable named flo
	departments = json.load(json_data)
	print(departments['results'][0]['name'])
	print(departments['results'][1]['name'])