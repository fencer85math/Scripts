#!/bin/bash

# Home Directory Listing
# By: Adrian Steffen
#
# Exercise from TLDP Advanced Bash Scripting Guide
# Perform a  recursive direcotry listing on the user's home direcory
# and save the information to a file. Compress the file, have the
# script promt the user to insert a USB Flash drive, then press ENTER.
# Finally, save the file to the flashdrive afer making certain the
# flash drive has properly mounted by parsing the output of df. Note
# that the flashdrive must be unmounted before it is removed.


# Perform a recursive direcotry listing on the user's home direcory
# and save the information to a file. 
ls -laR ~ >> "$(whoami)-homedirListing"

# Compress the file, 
tar -czvf "$(whoami)-compressed.tar.gz" "$(whoami)-homedirListing"

# have the script promt the user to insert a USB Flash drive, then press ENTER.


# Finally, save the file to the flashdrive afer making certain the
# flash drive has properly mounted by parsing the output of df. Note
# that the flashdrive must be unmounted before it is removed.


