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

export FILE=/opt/sensu/plugins/ctm/.secret-settings.json
ECHO='/usr/bin/echo'
#######################################
### Verifying the parameters' number
#######################################
if [ "$#" -ne 2 ]; then
        $ECHO "Illegal number of parameters"
        $ECHO "USAGE: $0 database nameOfSecret"
        exit 2
fi


#############
## Variables
#############
SQLPLUS64='/usr/bin/sqlplus64'
GREP='/usr/bin/grep'
CAT='/usr/bin/cat'
DB=$1
SECRET=$2
APIKEY=$($CAT $FILE |jq '.["api-key"]'| cut -d "\"" -f 2)
API_ID=$($CAT $FILE |jq '.["api-id"]'| cut -d "\"" -f 2)
ENDPOINT=$($CAT $FILE |jq '.["endpoint"]'| cut -d "\"" -f 2)
#Get the credentials
PASS_TEST=$(curl -s -X POST https://$ENDPOINT -H "x-apigw-api-id:$API_ID" -H "x-api-key:$APIKEY" -d '{"secret": '\"$SECRET\"' }'|grep "not found")
        if [ $? -eq 0 ]
                then
                $ECHO "UNKNOWN - The secret $SECRET was not found; Check it with monitoring team!"
                exit 3
        fi


USERNAME=$(curl -s -X POST https://$ENDPOINT -H "x-apigw-api-id:$API_ID" -H "x-api-key:$APIKEY" -d '{"secret": '\"$SECRET\"' }' 2> /dev/null|jq '.["username"]'| cut -d "\"" -f 2  )
PASSWORD=$(curl -s -X POST https://$ENDPOINT -H "x-apigw-api-id:$API_ID" -H "x-api-key:$APIKEY" -d '{"secret": '\"$SECRET\"' }' 2> /dev/null |jq '.["password"]'| cut -d "\"" -f 2 )


#############################################################
## try connection and look for string "connected"
############################################################
$ECHO "exit" | $SQLPLUS64 -L $USERNAME/$PASSWORD@$DB |$GREP "Connected" -A1 > /dev/null

        if [ $? -eq 0 ]
                then
                $ECHO "OK - $DB is UP and login is possible"
                exit 0
        elif [ $? -eq 1 ]
                then
                $ECHO "CRITICAL - We could not connect to $DB"
                exit 2
        fi
