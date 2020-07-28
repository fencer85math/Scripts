#! /bin/sh
#
# @file mysshgen - automate SSH key generation for Quoin Inc.
#
#
# @section Synopsis
#
#   mysshgen [-h|-v|-z] -u Provide username,
#                       -n Provide hostname of machine,
#                       -p Provide the passphrase for key,
#                       -f Provide the user certificate number,
#                       -e Provide the host certificate number,
#                       -q Provide the user ssh directory path,
#                       -s Provide the host ssh directory path,
#                       -t Provide the certificate authority ssh directory path,
#                       -o Automatically overwrite existing files
#                       -h Print this help message and exit,
#                       -v Print the version of the program and exit,
#                       -z Run the Unit Tests for the program
#
# @section Description
#
#    The basic process is to validate the input, generate the SSH keys,
#    sign certificates, with validation after the each step.
#    This script is to fully automate SSH key generation.
#    It includes command line arguments to pass in the necessary
#    information. 
#    
#    Implemented changes to validation of input (nonempty
#    strings) and existence of directories, unit tests were incorporated
#    with an argument, empty-expect was used to further minimze levels
#    of interaction, basic checks were implemented for directory
#    permissions and ownership.
#
#    Added functionality to get the last certificate serial number from
#    the Certificate Authority Index file and incriment the next two
#    certificates (user and host). 
#
#    Added functionality to update the Certificate Authority Index file
#    with the recently generated SSH Keys. 
#
# @section Options
#
#    The following options are required to run the script.
#        1. the username (-u)
#        2. the hostname of machine (-n)
#        3. the passphrase for key (-p)
#        4. the user ssh directory path (-q)
#        5. the host ssh directory path (-s)
#        6. the certificate authority ssh directory path (-t)
#
#        NOTE: The email address and Fully Qualified Domain Name are
#        inferred from the username and hostname.
#
# @section Prerequisities
#
#   This is POSIX compliant and should run on any relatively recent Unix
#   system with the following software dependencies: 
#   empty-expect package for Debian-based machines.
#
# @section Bugs
#
#   * If there are no files in hosts ssh/, certificates are generated,
#     but cannot be verified. If files are overwritten, no errors are
#     generated. - Proposed resolution - run script 2x
#   * will duplicate certificate numbers once before incrimenting the
#     next certificate number - RESOLVED
#   * Output in the process shows certificate information for the
#     previous certificate for that user/host, not the certificate
#     information most recently generated. - Proposed resolution -
#     ignore output

set -e -u

my_program_name='mysshgen.sh'
my_no_args=0

# Two variables for setting what the owner and group SHOULD be
readonly my_proper_owner='main'
readonly my_proper_group='main'
readonly my_proper_permits=0700

##
# Unit tests for the script
#
my_ssh_keygen_unit_tests()
{
  oneTimeSetUp()
  {
    install -d -o "${my_proper_owner}" -g "${my_proper_group}" -m 700 fakedir
  }
  
  oneTimeTearDown()
  {
    rmdir fakedir
  }
  
  ##
  # Success prints usage information
  # Failure prints none or other information
# removed the following 2 lines below the -p line
#Usage: mysshgen.sh [-h | -v | -z] -u [arg] -n [arg] -f [arg] -e [arg] -p [arg] -q [arg] -s [arg] -t [arg]
#-f Provide the user certificate number.
#-e Provide the host certificate number.
  testmy_usage()
  {
    assertEquals 'Usage: mysshgen.sh [-h | -v | -z] -u [arg] -n [arg] -p [arg] -q [arg] -s [arg] -t [arg]

-u Provide username.
-n Provide hostname of machine.
-p Provide the passphrase for key.
-q Provide the user ssh directory path
-s Provide the host ssh directory path
-t Provide the certificate authority ssh directory path
-h Print this help message and exit.
-v Print the version of the program and exit.
-z Run the Unit Tests for the program.' "$(my_usage)"
  }
  
  ##
  # Success prints help information
  # Failure prints none or other information
# removed the following 2 lines below the -p line
#Usage: mysshgen.sh [-h | -v | -z] -u [arg] -n [arg] -f [arg] -e [arg] -p [arg] -q [arg] -s [arg] -t [arg]
#-f Provide the user certificate number.
#-e Provide the host certificate number.
  testmy_help()
  {
    assertEquals "mysshgen.sh - Quoin Inc's directory to CSV converter.
Copyright 2016 Quoin Inc
Usage: mysshgen.sh [-h | -v | -z] -u [arg] -n [arg] -p [arg] -q [arg] -s [arg] -t [arg]

-u Provide username.
-n Provide hostname of machine.
-p Provide the passphrase for key.
-q Provide the user ssh directory path
-s Provide the host ssh directory path
-t Provide the certificate authority ssh directory path
-h Print this help message and exit.
-v Print the version of the program and exit.
-z Run the Unit Tests for the program." "$(my_help)"
  }
   
  ##
  # Success prints version information
  # Failure prints none or other information
  testmy_version()
  {
    assertEquals 'mysshgen.sh @(#) $ Name $.' "$(my_version)"
  }
  
  ##
  # Success returns control to caller
  # Failure prints none or other informtaion
  testmy_validate_nonempty_success()
  {
    assertEquals '' "$(my_validate_nonempty 'snarfblot' 'something failed')"
  }
  
  testmy_validate_nonempty_failure()
  {
    assertEquals 'mysshgen.sh - Empty String Failure' "$(my_validate_nonempty '' 'Empty String Failure' 2>&1)"
  }
  
  testmy_validate_dir_exist_success()
  {
    assertEquals '' "$(my_validate_dir_exist 'fakedir' 'Directory does not exist' 2>&1)"
  }
  
  testmy_validate_dir_exist_failure()
  {
    assertEquals 'mysshgen.sh - Directory does not exist' "$(my_validate_dir_exist 'fakedir2' 'Directory does not exist' 2>&1)"
  }
  
  testmy_validate_equality_option_not_recognized()
  {
    assertEquals 'mysshgen.sh - hello, world - Option not recognized - pass or fail only.' "$(my_validate_numeral_equality '134' '123' 'hello, world' 'Passed numbers are not equal' 2>&1 )" 
  }
  
  testmy_validate_equality_success_failure()
  {
    assertEquals 'mysshgen.sh - Passed numbers are not equal' "$(my_validate_numeral_equality '134' '135' 'pass' 'Passed numbers are not equal' 2>&1)" 
  }
  
  testmy_validate_equality_success_success()
  {
    assertEquals '' "$(my_validate_numeral_equality '134' '134' 'pass' 'Passed numbers are not equal')" 
  }
  
  testmy_validate_equality_failure_success()
  {
    assertEquals '' "$(my_validate_numeral_equality '134' '135' 'fail' 'Passed numbers are not equal' 2>&1 )" 
  }
  
  testmy_validate_equality_failure_failure()
  {
    assertEquals 'mysshgen.sh - Passed numbers are not equal' "$(my_validate_numeral_equality '134' '134' 'fail' 'Passed numbers are not equal' 2>&1 )" 
  }
  
  ## Call and run all tests
  . "shunit2"
  
}

##
# Print usage message.
# 
my_usage()
{
  printf 'Usage: %s [-h | -v | -z] -u [arg] -n [arg] -p [arg] -q [arg] -s [arg] -t [arg] -o\n' "${my_program_name}"
  printf '\n'
  printf '%s\n' '-u Provide username.'
  printf '%s\n' '-n Provide hostname of machine.'
  printf '%s\n' '-p Provide the passphrase for key.'
  printf '%s\n' '-q Provide the user ssh directory path'
  printf '%s\n' '-s Provide the host ssh directory path'
  printf '%s\n' '-t Provide the certificate authority ssh directory path'
  printf '%s\n' '-o Automatically overwrite existing files'
  printf '%s\n' '-h Print this help message and exit.'
  printf '%s\n' '-v Print the version of the program and exit.'
  printf '%s\n' '-z Run the Unit Tests for the program.'
}

##
# Print help message.
#
my_help()
{
  printf '%s - %s\n' "${my_program_name}" "Directory to CSV converter."
  printf '%s\n' "Copyright 2016"

  my_usage
}

##
# Print program version.
#
my_version()
{
  printf '%s %s.\n' "${my_program_name}" '@(#) $ Name $'
}

##
# Retrieve the last certificate number and incriment the user_cert and
#  host_cert numbers by 1
#
my_get_next_serial_numbers()
{
  if [ -e "${my_ca_ssh_dir}index.txt" ]
  then
    my_last_ca_number=$(tail -n 1 "${my_ca_ssh_dir}index.txt" | tr -s ' ' | cut -d ' ' -f 2)
    my_user_cert_number=$((my_last_ca_number + 1))
    my_host_cert_number=$((my_last_ca_number + 2))
  else
    printf '%s - %s\n' "${my_program_name}" 'ERROR: CA index.txt file does not exist' >&2
  fi
  
  unset my_last_ca_number

  return
}

##
# Update the CA Index with recent key generations
#
# @params File name of certificate to extract information from
my_update_ca_index()
{
  sleep 1
  if [ -e "${my_ca_ssh_dir}index.txt" ]
  then
    my_ssh_file_serial=$(ssh-keygen -L -f "${1}" | grep 'Serial: ' | tr -s ' ' | cut -d ' ' -f 3)
    my_ssh_file_type=$(ssh-keygen -L -f "${1}" | grep 'Type' | tr -s ' ' | cut -d ' ' -f 4)
    my_ssh_file_keyid=$(ssh-keygen -L -f "${1}" | grep 'ID' | tr -s ' ' | cut -d ' ' -f 4 | sed -e 's/^"//' -e 's/"$//')
    my_ssh_file_principal=$(ssh-keygen -L -f "${1}" | grep 'Principal' -A 1 | tail -n 1 | tr -s ' ')
    my_ssh_file_key=$(ssh-keygen -L -f "${1}" | grep 'Public' | tr -s ' ' | cut -d ':' -f 2-3)
    my_ssh_file_begin_date=$(ssh-keygen -L -f "${1}" | grep 'Valid' | tr -s ' ' | cut -d ' ' -f 4)
    my_ssh_file_end_date=$(ssh-keygen -L -f "${1}" | grep 'Valid' | tr -s ' ' | cut -d ' ' -f 6)

    printf '\n%5s %7s %-23s %-23s  %s  %s  %s' "${my_ssh_file_serial}" "${my_ssh_file_type}" "${my_ssh_file_keyid}" "${my_ssh_file_principal}" "${my_ssh_file_key}" "${my_ssh_file_begin_date}" "${my_ssh_file_end_date}" >> "${my_ca_ssh_dir}index.txt"
  else
    printf '%s - %s\n' "${my_program_name}" 'ERROR: CA index.txt file does not exist' >&2
  fi

  unset my_ssh_file_serial
  unset my_ssh_file_type
  unset my_ssh_file_keyid
  unset my_ssh_file_principal
  unset my_ssh_file_key
  unset my_ssh_file_begin_date
  unset my_ssh_file_end_date

  return
}

##
# Generate User Elliptical Key
#
# @return int - exit status of function 0 - success/1 - error
my_gen_user_ssh_key()
{
  my_user_ssh_keys="${my_user_ssh_dir}id_ed25519"
  
#  if [ 0 -eq "${my_overwrite}" ]
#  then
#    mysshgen_FIFO1='ssh-keygen-user-input'
#    mysshgen_FIFO2='ssh-keygen-user-output'
#    empty -f -i "${mysshgen_FIFO1}" -o "${mysshgen_FIFO2}" ssh-keygen -t 'ed25519' -o -a '100' -C "${my_user_email}" -N "${my_user_passphrase}" -f "${my_user_ssh_keys}"
#    empty -w -i "${mysshgen_FIFO2}" -o "${mysshgen_FIFO1}" 'verwrite'
#    empty -s -o "${mysshgen_FIFO1}" 'y\n'
#    unset mysshgen_FIFO1
#    unset mysshgen_FIFO2
#    my_gen_user_ssh_key_status=0
#  else
    if ssh-keygen -t 'ed25519' -o -a '100' -C "${my_user_email}" -N "${my_user_passphrase}" -f "${my_user_ssh_keys}"
    then
      my_gen_user_ssh_key_status=0
    else
      my_gen_user_ssh_key_status=1
      printf '%s - %s\n' "${my_program_name}" 'ERROR: ssh-keygen user key generation' >&2
    fi
#  fi

  unset my_user_ssh_keys

  return "${my_gen_user_ssh_key_status}"
}

##
# Sign user certificate
#
# @return int - exit status of function 0 - success/1 - error
my_sign_user_cert()
{
  my_user_cert="${my_user_ssh_dir}id_ed25519-cert.pub"
  my_user_pub="${my_user_ssh_dir}id_ed25519.pub"
  mysshgen_FIFO1='ssh-keygen-input'
  mysshgen_FIFO2='ssh-keygen-output'
  empty -f -i "${mysshgen_FIFO1}" -o "${mysshgen_FIFO2}" -p emptypid.pid ssh-keygen -s "${my_ca_ssh_dir}id_ed25519" -I "${my_user_email}" -n "${my_user_name}" -V '+365d' -z "${1}" -f "${my_user_cert}" "${my_user_pub}"
  empty -w -i "${mysshgen_FIFO2}" -o "${mysshgen_FIFO1}" 'passphrase:'
  empty -s -o "${mysshgen_FIFO1}" < "$my_ca_ssh_dir/passphrase"
  empty -s -o "${mysshgen_FIFO1}" '\n'

  unset my_user_cert
  unset my_user_pub
  unset mysshgen_FIFO1
  unset mysshgen_FIFO2

  return
}

##
# Verify signed user certificate
#
# @return int - exit status of function 0 - success/1 - error
my_verify_user_cert()
{
  my_user_signed_cert="${my_user_ssh_dir}id_ed25519-cert.pub"
  sleep 1

  if ssh-keygen -L -f "${my_user_signed_cert}"
  then
    my_verify_user_cert_status=0
  else
    my_verify_user_cert_status=1
    printf '%s - %s\n' "${my_program_name}" 'ERROR: ssh-keygen verifying user certificate in method' >&2
  fi

  unset my_user_signed_cert

  return "${my_verify_user_cert_status}"
}

##
# Generate Host Elliptical Key
#
# @return int - exit status of function 0 - success/1 - error
my_gen_host_ssh_key()
{
  my_host_ssh_key="${my_host_ssh_dir}ssh_host_ed25519_key"

#  if [ 0 -eq "${my_overwrite}" ]
#  then
#    mysshgen_FIFO1='ssh-keygen-host-gen-input'
#    mysshgen_FIFO2='ssh-keygen-host-gen-output'
#    empty -f -i "${mysshgen_FIFO1}" -o "${mysshgen_FIFO2}" ssh-keygen -t 'ed25519' -o -a '100' -C "${my_host_fqdn}" -N '' -f "${my_host_ssh_key}"
#    empty -w -i "${mysshgen_FIFO2}" -o "${mysshgen_FIFO1}" 'verwrite'
#    empty -s -o "${mysshgen_FIFO1}" 'y\n'
#    unset mysshgen_FIFO1
#    unset mysshgen_FIFO2
#    my_gen_host_ssh_key_status=0
#  else
    if ssh-keygen -t 'ed25519' -o -a '100' -C "${my_host_fqdn}" -N '' -f "${my_host_ssh_key}"
    then
      my_gen_host_ssh_key_status=0
    else
      my_gen_host_ssh_key_status=1
      printf '%s - %s\n' "${my_program_name}" 'ERROR: ssh-keygen user key generation' >&2
    fi
#  fi
    
  unset my_host_ssh_key

  return "${my_gen_host_ssh_key_status}"
}

##
# Sign host certificate
#
# @return int - exit status of function 0 - success/1 - error
my_sign_host_cert()
{
  my_host_cert="${my_host_ssh_dir}ssh_host_ed25519_key-cert.pub"
  my_host_pub="${my_host_ssh_dir}ssh_host_ed25519_key.pub"
  
  mysshgen_FIFO1='ssh-keygen-host-input'
  mysshgen_FIFO2='ssh-keygen-host-output'
  empty -f -i "$mysshgen_FIFO1" -o "$mysshgen_FIFO2" ssh-keygen -h -s "${my_ca_ssh_dir}id_ed25519" -I "${my_host_fqdn}" -n "${my_host_fqdn}" -V '+365d' -z "${1}" -f "${my_host_cert}" "${my_host_pub}"
  empty -w -i "$mysshgen_FIFO2" -o "$mysshgen_FIFO1" 'passphrase:'
  empty -s -o "$mysshgen_FIFO1" < "$my_ca_ssh_dir/passphrase"
  empty -s -o "$mysshgen_FIFO1" '\n'

  unset my_host_cert
  unset my_host_pub
  unset mysshgen_FIFO1
  unset mysshgen_FIFO2

  return
}

##
# Verify signed host certificate
#
# @return int - exit status of function 0 - success/1 - error
my_verify_host_cert()
{
  my_host_signed_cert="${my_host_ssh_dir}ssh_host_ed25519_key-cert.pub"
  
  if ssh-keygen -L -f "${my_host_signed_cert}"
  then
    my_verify_host_cert_status=0
  else
    my_verify_host_cert_status=1
    printf '%s - %s\n' "${my_program_name}" 'ERROR: ssh-keygen verifying host certificate in method' >&2
  fi

  unset my_host_signed_cert

  return "${my_verify_host_cert_status}"
}

##
# Validate variable is nonempty
#
# @params variable to test for nonempty
# @params string for failure case
# @return int - exit status of function 0 - success/1 - error
my_validate_nonempty()
{
  if [ -z "${1}" ]
  then
    printf '%s - %s\n' "${my_program_name}" "${2}" >&2
    my_validate_nonempty_status=1
  else
    my_validate_nonempty_status=0
  fi

  return "${my_validate_nonempty_status}"
}

##
# Validate existence of directories
#
# @param 1 string - inputed variable to test for nonempy
# @param 2 string - error message for failure case
# @return int - exit status of function 0 - success/1 - error
my_validate_dir_exist()
{
  if [ -e "${1}" ]
  then
    my_perm=$(stat -c"%a" "${1}")
    my_group=$(stat -c"%G" "${1}")
    my_owner=$(stat -c"%U" "${1}")
  fi

  if [ -d "${1}" ]
  then
    if [ "${my_proper_permits}" -eq "${my_perm}" ]
    then
      if [ "${my_proper_owner}" = "${my_owner}" ]
      then
        if [ "${my_proper_group}" = "${my_group}" ]
        then
          my_validate_dir_status=0
        else
          printf '%s - %s - %s\n' "${my_program_name}" "${1}" 'ERROR: Directory is in the wrong group' >&2
          my_validate_dir_status=1
        fi
      else
        printf '%s - %s - %s\n' "${my_program_name}" "${1}" 'ERROR: Directory is owned by someone else' >&2
        my_validate_dir_status=1
      fi
    else
      printf '%s - %s\n - %s' "${my_program_name}" "${1}" 'ERROR: Directory has the wrong permissions' >&2
      my_validate_dir_status=1
    fi
  else
    printf '%s - %s\n' "${my_program_name}" "${2}" >&2
    my_validate_dir_status=1
  fi

  unset my_perm
  unset my_group
  unset my_owner

  return "${my_validate_dir_status}"
}

##
# Validate state of equality 
#
# @param String - First variable name to determine equality
# @param String - Second variable name to determine equality
# @param String - Equality is pass or fail ('fail' or 'pass' are the defaults)
# @param String - Error message for failure case
# @return int - exit status of function 0 - success/1 - error
my_validate_numeral_equality()
{
  if [ 'fail' = "${3}" ]
  then
    if [ "${1}" -eq "${2}" ]
    then
      printf '%s - %s\n' "${my_program_name}" "${4}" >&2
      my_validation_equality_status=1
    else
      my_validation_equality_status=0
    fi
  elif [ 'pass' = "${3}" ]
  then
    # If equality is a success case
    if [ "${1}" -eq "${2}" ]
    then
      my_validation_equality_status=0
    else
      printf '%s - %s\n' "${my_program_name}" "${4}" >&2
      my_validation_equality_status=1
    fi
  else
    printf '%s - %s - %s\n' "${my_program_name}" "${3}" 'Option not recognized - pass or fail only.' >&2
    my_validation_equality_status=1
  fi

  return "${my_validation_equality_status}"
}

##
# Validation of input for ssh key generation.
#
my_validate_input()
{
  my_validation_status=1
  if my_validate_nonempty "${my_user_name}" 'ERROR: User Name not provided.'
  then
    my_validation_status=0
    if my_validate_nonempty "${my_host_name}" 'ERROR: Host Name not provided.'
    then
    my_validation_status=0
      if my_validate_nonempty "${my_user_passphrase}" 'ERROR: Passphrase not provided'
      then
        my_validation_status=0
        if my_validate_numeral_equality "${my_user_cert_number}" "${my_host_cert_number}" 'fail' 'ERROR: User and Host Certificate Numbers cannot be the same.'
        then
          my_validation_status=0
          if my_validate_dir_exist "${my_user_ssh_dir}" 'ERROR: User SSH directory does not exist'
          then
            my_validation_status=0
            if my_validate_dir_exist "${my_host_ssh_dir}" 'ERROR: Host SSH directory does not exist'
            then
              my_validation_status=0
              if my_validate_dir_exist "${my_ca_ssh_dir}" 'ERROR: CA SSH directory does not exist'
              then
                my_validation_status=0
              else
            printf '%s - %s\n' "${my_program_name}" 'ERROR: CA SSH directory does not exist.'
              fi
            else
              printf '%s - %s\n' "${my_program_name}" 'ERROR: Host SSH directory does not exist.'
            fi
          else
            printf '%s - %s\n' "${my_program_name}" 'ERROR: User SSH directory does not exist.'
          fi
        else
          printf '%s - %s\n' "${my_program_name}" 'ERROR: User and Host Certificates need to be different by 1.'
        fi
      else
        printf '%s - %s\n' "${my_program_name}" 'ERROR: A passphrase is required.'
      fi
    else
      printf '%s - %s\n' "${my_program_name}" 'ERROR: Host name is required.'
    fi
  else
    printf '%s - %s\n' "${my_program_name}" 'ERROR: User name is requrired.'
  fi
      
  return "${my_validation_status}"
}

##
# Generate the ssh keys for desired user
#
my_generate_ssh_keys()
{
  if ! my_validate_input
  then
    printf '%s - %s\n' "${my_program_name}" 'ERROR: Invalid input.'
    exit 1
  fi

  if ! my_gen_user_ssh_key
  then
    printf '%s - %s\n' "${my_program_name}" 'ERROR: issue generating user ssh key.'
    exit 1
  fi

  if ! my_gen_host_ssh_key
  then    
    printf '%s - %s\n' "${my_program_name}" 'ERROR: issue generating host ssh key.'
    exit 1
  fi

  if ! my_sign_user_cert "${my_user_cert_number}"
  then
    printf '%s - %s\n' "${my_program_name}" 'ERROR: issue signing user certificate.'
    exit 1
  fi

  if ! my_sign_host_cert "${my_host_cert_number}"
  then
    printf '%s - %s\n' "${my_program_name}" 'ERROR: issue signing host certificate.'
    exit 1
  fi

  if ! my_verify_user_cert
  then
    printf '%s - %s\n' "${my_program_name}" 'ERROR: issue validating user certificate in process.'
    exit 1
  fi

  if ! my_verify_host_cert
  then
    printf '%s - %s\n' "${my_program_name}" 'ERROR: issue validating host certificate in process.'
    exit 1
  fi

  printf '%s - %s\n' "${my_program_name}" 'SSH Key Generation and signing completed successfully.'
  my_update_ca_index "${my_user_ssh_dir}id_ed25519-cert.pub"
  my_update_ca_index "${my_host_ssh_dir}ssh_host_ed25519_key-cert.pub"
  printf '%s - %s\n' "${my_program_name}" 'Certificate Authority Index updated.'
}

## @name main
## @{

  readonly mysshgen_openssh_pkg_name_conf='openssh-client'
  readonly mysshgen_openssh_pkg_version_conf='1:7.2p2-4~my+bpo8+1'
  readonly mysshgen_empty_pkg_name_conf='empty-expect'
  readonly mysshgen_empty_pkg_version_conf='0.6.19b-1'

  if [ 'install' = "$(dpkg --get-selections "${mysshgen_openssh_pkg_name_conf}" | awk \{'printf $2'\})" ]
  then
    if [ 'install' = "$(dpkg --get-selections "${mysshgen_empty_pkg_name_conf}" | awk \{'printf $2'\})" ]
    then
      if [ $# -eq "${my_no_args}" ]
      then
        my_usage
        exit 1
      fi
      
      while getopts 'hvzou:n:p:q:s:t:' OPT
      do
        case "${OPT}" in
          
          u) readonly my_user_name="${OPTARG}"
             readonly my_user_email="${OPTARG}@quoininc.com"
             ;;
      
          n) readonly my_host_name="${OPTARG}"
             readonly my_host_fqdn="${OPTARG}.quoininc.com"
             ;;
    
          p) readonly my_user_passphrase="${OPTARG}"
             ;;
    
          q) readonly my_user_ssh_dir="${OPTARG}"
             ;;
    
          s) readonly my_host_ssh_dir="${OPTARG}"
             ;;
    
          t) readonly my_ca_ssh_dir="${OPTARG}"
             my_get_next_serial_numbers
             ;;

          o) readonly my_overwrite=0
             ;;
    
          z) my_ssh_keygen_unit_tests
             exit 0
             ;;
    
          h) my_usage
             exit 0
             ;;
      
          v) my_version
             exit 0
             ;;
          
          --) shift; 
              break;;
    
          :) printf '%s: Error: Required option parameter missing. option="-%s\.\n' "${my_program_name}" "${OPTARG}" >&2
             my_usage >&2
             exit 1
             ;;
      
          \?) printf 'Please enter nonempty argument.\n'
             my_usage >&2
             exit 1 
             ;;
        esac
      done
      
      shift "$((OPTIND - 1))"
    
      my_generate_ssh_keys
      unset my_user_cert_number
      unset my_host_cert_number
    else
      printf '%s: Error: missing utility. Please install %s and try again.\n' "${my_program_name}" "${mysshgen_empty_pkg_name_conf}"
    fi
  else
    printf '%s: Error: missing utility. Please install %s and try again.\n' "${my_program_name}" "${mysshgen_openssh_pkg_name_conf}"
  fi

## @}
