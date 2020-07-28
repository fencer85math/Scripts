#! /bin/expect
#=====================================================================
# Author : Adrian Steffen
# Date   : 07/20/2015
# Purpose: This script is to run a command against remote wireless routers to get
#          generic IPs on a designated wireless network, and send an
#          email with the results of the script upon completion.
# WARNING: Password is not protected when stored in the file...
#=====================================================================
set timeout 10
set prog [file tail $argv0]
set outLog "ipfinding.log"
set mailpath {mailx}
set subject {DMP IP Script is completed.} 
set counter 0 
set filething ".routerrunner"

# Conditional checks for an existing file called ".routerrunner".
# The file should be set up with the following items in the specified 
# order on separate lines:
# 1) gls1 login name
# 2) file with store numbers to go through 
# 3) TACACS login 
# 4) TACACS password 
# 5) email address to email upon completion.

if {[file exists $filething]} {
   set fn [open $filething r]
   set dmpList [read $fn]

   foreach line $dmpList {
      if {$counter == 4} {
         set emailaddy $line
      }
      if {$counter == 3} {
         set tacpwd $line
      }
      if {$counter == 2} {
         set taclgn $line
      }
      if {$counter == 1} {
         set filename $line
         set f [open /home/login/$glslogin/$filename]
      }
      if {$counter == 0} {
         set glslogin $line
      }
      incr counter
   }
# end foreach
} else {
   # gathers the following information for automation:
   # 1) Gls1 login
   # 2) File with store numbers to loop through
   # 3) File with TACACS login information
   #    login and password should be on separate lines
   # 4) Sets up email for script results

   puts "gls1 login name: "
   set glslogin [gets stdin]
   puts "Name of file with store numbers: "
   set filename [gets stdin]
   set f [open /home/login/$glslogin/$filename]
   set fout [open /home/login/$glslogin/email.txt w]
   puts "Name of file with TACACS: "
   set ftacin [gets stdin]
   set tacfile [open /home/login/$glslogin/$ftacin]

   set counter 0
   foreach line [split [read $tacfile] \n] {
         if {$counter == 0} {
            set taclgn $line
            }
         if {$counter == 1} {
            set tacpwd $line
            }
         incr counter
      }
   close $tacfile
   puts "Enter email address: "
   set emailaddy [gets stdin]

   # After collecting information, prompts user if the
   # information should be saved to the local directory
   # for later use. Changes permissions of written file
   # to -rw-------.
   # Notable security risk

   puts "Save information to a file? Yes or No? "
   set answer [gets stdin]
   if {$answer == "Yes" } {
      set fp [open $filething w]
      puts $fp $glslogin
      puts $fp $filename
      puts $fp $taclgn
      puts $fp $tacpwd
      puts $fp $emailaddy
      close $fp
      spawn -noecho chmod 600 $filething
   }
}

# Filters "show wireless client" to show only entries with 
# DMP0 in the hostname. Normally will show designated devices 
# with generic IP addresses. (modification would be to use regex
# to look for IP addresses in a particular range)

set cmd "show wireless client | incl DMP0"

proc diaglog { prog msg } {
   global outLog
   set lfp [open $outLog a ]
   puts $lfp [format "%s %s %s" [clock format [clock seconds] \
                 -format "%D %T"] $prog $msg]
   close $lfp
}

set mfp [open "|$mailpath -s \"$subject \" $emailaddy" w]

foreach line [split [ read $f] \n] {
   set pwdCnt 0
   set cmdCnt 0
   puts "\n$line"

   spawn -noecho ssh -l "PasswordAuthenitcation no" $taclgn@router1.$line

   expect {
    "Connection closed" {
        diaglog $prog "Error: Connection closed"
        exp_continue
        #close "Connection closed"
        }

    "Cannot handle term 'ibm3151'. Setting term to dumb." {
        exp_continue
    }

    "*Store-5GHz-1x-Mobility*\n" {
        puts $mfp $expect_out(buffer)
    }

    "assword:" {
         after 2000
         if {[incr pwdCnt] < 3} {
             exp_send "$tacpwd\r"
             exp_continue
         } else {
             diaglog $prog "$line Error: Password failed"
             close
             }
         # close "assword:"
         }

     "Permission denied" {
         after 2000
         diaglog $prog "$line Permission denied"
         exp_continue
         # close "Permission denied"
         }

      "$line*>" {
         if {[incr cmdCnt] < 2} {
            exp_send "$cmd\r"
            # Prompts :Enter for next line, Space for next page
            # Q for quit, R to show the rest
            exp_send "\n"
            # to show the rest of the devices on wireless network
            exp_send "R"
            exp_continue
        puts stdout $logger
         } else {
            # to exit the switch prior to starting the next login
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

# to "rewrite" tacacs information to "blanks"
set taclgn "00000000000"
set tacpwd "00000000000"
