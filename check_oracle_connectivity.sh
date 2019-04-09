#!/bin/sh
#==========================================================================================
#This script will check if a given user can access to a given Oracle database.
#==========================================================================================
# Written by Etienne Delsy, EDRANS 

# Plugin return codes:
# 0     OK
# 1     Warning
# 2     Critical
# 3     Unknown

###########################################################################################



############# 
## Variables
#############
ECHO='/usr/bin/echo'
SQLPLUS64='/usr/bin/sqlplus64'
GREP='/usr/bin/grep'
USER=$1
PASS=$2
DB=$3

#######################################
### Verifying the parameters' number
#######################################
if [ "$#" -ne 3 ]; then
        $ECHO "Illegal number of parameters"
        $ECHO "USAGE: $0 user password database"
        exit 2
fi

#############################################################
## try connection and look for string "connected"
############################################################
$ECHO "exit" | $SQLPLUS64 -L $USER/$PASS@$DB |$GREP "Connected" -A1 > /dev/null

        if [ $? -eq 0 ]
                then
                $ECHO "OK - $DB is UP and login is possible"
                exit 0
        elif [ $? -eq 1 ]
                then
                $ECHO "CRITICAL - We could not connect to $DB"
                exit 1
        fi
