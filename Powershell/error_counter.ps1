# Error Counter - counts number of disk and ntfs errors in system event log
# By Adrian Steffen
#
# Counting disk/ntfs errors in a System.evtx
#
# wonderlandcounter.ps1 > error_counter.ps1
# modified script to look for disk/ntfs errors in System.evtx files
# attempting to look for disk/ntfs strings
# 
# error_counter.ps1 > error_counter2.ps1
# Changed from looking for strings to using Get-WinEvent
# Since System.evtx is a Hashtable, -FilterHashtable option is used
# Measure-Object is used to count the entries with the ProviderName
# .Count is used to get a numerical format
# Pauses script when run to enable time to view information.
#
# PowerShell command that works is: PS C:\Users\asteffen> Get-WinEvent -FilterHashtable @{Path="C:\Users\asteffen\Documents\
# DMP Eventlogs\older event logs\dmp013.0056\System.evtx";ProviderName="disk";} | Measure-Object
#
# error_counter2.ps1 > error_counter3.ps1
# Add Try-Catch to prevent errors from showing while running
# Add -ErrorAction Stop to Get-WinEvent command to prevent errors from showing up
# ItemNotFound is a the trouble here is that it is a non-terminating error. 
# So even though it is a ItemNotFoundException, it isn't actually getting thrown 
# unless wrapped in a ActionPreferencesStopException
#
# error_counter3.ps1 > error_counter4.ps1
# Generalize to ask for local file or a remote file
#
# error_counter4.ps1 > error_counter5.ps1
# Get the remote option to work remote file

Clear-Host

# On a remote system:
#$FileName = "\\dmp013.0056.lowes.com\c$\Windows\System32\winevt\Logs\System.evtx"

$local = "local"
$local_abbrev = "l"
$remote = "remote"
$remote_abbrev = "r"
$userinput = Read-Host "Is the file local (l) or remote (r) "

if ($userinput -eq $local -OR $userinput -eq $local_abbrev) {
    # In a local directory, use Dialog Box to get file name
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
    Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    
    # Enables dialog box to show up when running with PowerShell.
    # Must be commented out to run in PowerShell ISE.
    $OpenFileDialog.ShowHelp = $true
    
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "All files (*.*)| *.*"
    $OpenFileDialog.ShowDialog() | Out-Null
    $FileName = $OpenFileDialog.filename

} elseif ($userinput -eq $remote -OR $userinput -eq $remote_abbrev) {

        Write-Host "Nothing here yet, ... coming soon!"

}

Write-Host "Reading file $FileName..." 
Try {
    $disk_errors = Get-WinEvent -FilterHashtable @{Path=$FileName;ProviderName="disk";} -ErrorAction Stop | Measure-Object
    $disk_count = $disk_errors.Count
 }
Catch {
    $disk_count = 0
 }

Try {
    $ntfs_errors = Get-WinEvent -FilterHashtable @{Path=$FileName;ProviderName="ntfs";} -ErrorAction Stop | Measure-Object
    $ntfs_count = $ntfs_errors.Count
 }
Catch  {
     $ntfs_count = 0
 }

Write-Host "Disk Errors: $disk_count"
Write-Host "NTFS Errors: $ntfs_count"

# Pauses script to get information
Write-Host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')