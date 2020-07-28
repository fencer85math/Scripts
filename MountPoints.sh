#! /bin/expect
#=====================================================================
# Author : Adrian Steffen
# Date   : 12/05/2017
# Purpose: This script is to run a command 
#          to determine the mount points of the nas.
#=====================================================================
set timeout 10
set prog [file tail $argv0]
set outLog "nasverify.log"
set mailpath {mailx}
set subject {Mount Verification Script is completed.}
set counter 0
set filething ".listrunner"

# Conditional checks for an existing file called ".listrunner".
# The file should be set up with the following items in the specified 
# order on separate lines:
# 1) login name
# 2) file with store numbers to go through
# 3) email address to email upon completion.

if {[file exists $filething]} {
   set fn [open $filething r]
   set storeList [read $fn]

   foreach line $storeList {
      if {$counter == 2} {
         set emailaddy $line
      }
      if {$counter == 1} {
         set filename $line
         set f [open /home/login/$glslogin/$filename]
      }
      if {$counter == 0} {
         set glslogin $line
      }
      incr counter
   # end foreach
   }
#end if
} else {
   # gathers the following information for automation:
   # 1) Gls1 login
   # 2) File to loop through
   # 3) Sets up email for script results

   puts "gls1 login name: "
   set glslogin [gets stdin]
   puts "Name of file with store numbers: "
   set filename [gets stdin]
   set f [open /home/login/$glslogin/$filename]
   set fout [open /home/login/$glslogin/email.txt w]

   puts "Enter email address: "
   set emailaddy [gets stdin]

   # After collecting information, prompts user if the
   # information should be saved to the local directory
   # for later use. Changes permissions of written file
   # to -rw-------.

   puts "Save information to a file? Yes or No? "
   set answer [gets stdin]   if {$answer == "Yes" } {
      set fp [open $filething w]
      puts $fp $glslogin
      puts $fp $filename
      puts $fp $emailaddy
      close $fp
      spawn -noecho chmod 600 $filething
   }
}

# Displays NAS mount points inside store with the directories

#set cmd "mount | grep nas1 | tr -s ' ' "

proc diaglog { prog msg } {
   global outLog
   set lfp [open $outLog a ]
   puts $lfp [format "%s %s %s" [clock format [clock seconds] \
                 -format "%D %T"] $prog $msg]
   close $lfp
}

set mfp [open "|$mailpath -s \"$subject \" $emailaddy" w]

# Go through list of stores and log into the store's ISP to
# verify the NAS mount points

foreach line [split [ read $f] \n] {
   set cmdCnt 0
   puts "\n$line"

   spawn -noecho go $line

   expect {
    "isp1.$line*>" {
       if {[incr cmdCnt] < 2} {
           set results [exp_send "mount | grep nas1 | tr -s ' '\r"]
           puts $mfp $results
           exp_continue
        } else {
           # Exit the ISP prior to starting the next login
           exp_send "exit\n"
           }
       # close "$line*"
       }
   # close expect
   }
# close foreach
}

close $mfp
close $f
