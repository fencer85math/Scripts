# LockMachine - locks machine multiple times
# By Adrian Steffen
#
# PRANK SCRIPT - no harm to the machine occurs; just an annoyance script
#
# LockMachineWrapper.ps1 is a wrapper to hide the window that this script
# launches. It can still be closed by terminating the powershell.exe
# process from the task manager.
#
# The original intent for this script is to be annoying when coworkers
# leave their machines unlocked.

start-process PowerShell.exe -arg $pwd\LockMachine.ps1 -WindowStyle Hidden