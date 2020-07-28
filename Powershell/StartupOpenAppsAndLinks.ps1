# Fresh Start - starts all necessary processes as determined by a user
# By Adrian Steffen
# Desc: Start all necessary programs upon initial start of notebook.
#       Grouped into 4 categories:
#       1) local processes
#       2) Chrome applications (user preference)
#       3) Internet Explorer applications (user preference)
#       4) Firefox applications (user preference)
# update 4 - generalized applications with environment variables
#          - expanded and clarified documentation
# update 3 - generalized user information
# update 2 - first set of optimizations

# TO ADD LINKS/PROGRAMS:
# 1) ADD a line in the corresponding section with 
# commenting the the link/program.
# 2) CREATE a new variable with the following format: $<Variable name> = "<link>". 
# 3) REPLACE <Variable name> with a unique name to identify the link.
# 4) REPLACE <link> with the URL within "".
# 5) ADD the new variable to the corresponding list:
#    $chrome_links, $ie_links, $local_applications, etc.
# 6) Save.
# 7) TEST!!!

# TO MODIFY EXISITNG LINKS AND BROWSERS
# 1) CUT the lines corresponding with the links (variable and comment line).
# 2) PASTE in the group where the link should open.
# 3) REMOVE the variable name from the previous list.
# 4) ADD the variable name to the new list.

### CHROME LINKS:
## List of links to open in Google Chrome#
# Link1
$chrome_link1 = "https://www.google.com"
# Link2
$chrome_link2 = "https://wwww.cnn.com"
$officeportal = "https://portal.office.com"
$chrome_links = $chrome_link1, $chrome_link2, $officeportal

### INTERNET EXPLORER LINKS## List of links to open in Internet Explorer#
# IE_link1
$IE_link1 = "https://dhcptool.lowes.com:8443/lowes/"
# IE_link2
$IE_link2 = "http://itstoresupport.lowes.com/"
# IE_link3
$IE_link3 = "https://verintwfo.lowes.com:7002/wfo/"
# IE_link4
$IE_link4 = "http://itsdportal.lowes.com"
# IE_link5
$IE_link5 = "https://awweb.lowes.com/AirWatch/Login"
# List of above links to open in IE
$ie_links = $IE_link1, $IE_link2, $IE_link3, $IE_link4, $IE_link5


### LOCAL PROCESSES/APPLICATIONS
## List of applications and processes that have been installed on the local machine.
#
# Multi-Tabbed Putty
$mtputty = "${env:HOMEPATH}\Desktop\PuTTY_MT.lnk"
# Putty (vanilla - no modifications)
$vanputty = "${env:HOMEPATH}\Putty\kitty.exe"
# Outlook - contractors must use portal.office.com#
$msoutlook = "${env:ProgramData}\Microsoft\Windows\Start Menu\Programs\Microsoft Office 2013\Outlook 2013.lnk"
# Display Fusion - task bar on all screens
$disp_fusion = "${env:ProgramFiles(x86)}\DisplayFusion\DisplayFusion.exe"
# Notepad
$notepad = "${env:windir}\system32\notepad.exe"
#List of local applications
$local_applications = $mtputty, $vanputty, $msoutlook, $disp_fusion, $notepad

### Start links in Google Chrome#
Foreach ($chrome_part in $chrome_links){ Start-Process "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe" $chrome_part}


### Start links in Internet Explorer#
Foreach ($ie_part in $ie_links){ Start-Process "${env:ProgramFiles(x86)}\Internet Explorer\iexplore.exe" $ie_part}


### Start links in Mozilla Firefox##
# Foreach ($ff_part in $ff_links){ Start-Process "${env:LOCALAPPDATA}\Mozilla Firefox\firefox.exe" $ff_part#} }


### Start local processes
## If the application (path) exists on the local machine, start the process
Foreach ($local_link in $local_applications){  if (Test-Path $local_link) {   Start-Process $local_link  }}
