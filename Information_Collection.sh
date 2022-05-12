#!/bin/bash

#Created by Riley Raso

#How to use the script:
#the Script can run on IPs,Emails,URLs,and domains by entering the information as the first parameter example below:
# Enter the following on your command line --> sh RR_SENG460Project.sh [Input]

# examples for different inputs:
# example one with IP --> sh RR_SENG460Project.sh 142.104.197.120
# example one with email --> sh RR_SENG460Project.sh bob@uvic.ca
# example one with website URL --> sh RR_SENG460Project.sh www.uvic.ca
# example one with domain --> sh RR_SENG460Project.sh uvic.ca

# only one parameter may be run at a time
# if input can not be turned into a domain than exit

#Changing any of the input into a domain
if [[ $1 =~ ([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5]) ]]; then
  #this is for an IP entered
  IPDomain=$(nslookup $1 | grep -Eo "name[ =A-Za-z.]+");
  tempValue=$(echo $IPDomain | cut -c 8- | grep -E "[A-Za-z.]+");
  condition=$(echo "${tempValue: -1}")
  if [[ $condition == '.' ]]; then
    tempValue=$(echo $tempValue | rev | cut -c 2- | rev)
  fi
  tempValue=$(echo $tempValue | rev | grep -Eo "([A-Za-z0-9]+\.[A-Za-z0-9]+)" | rev)
  Domain=$(echo $tempValue)
elif [[ $1 =~ [A-Za-z0-9+_-]+@[A-Za-z0-9+_-]+\.[A-Za-z0-9+_-]+ ]]; then
  # This is for an email address
  Domain=$(echo $1 | cut -d '@' -f 2);
elif [[ $1 =~ www\.[A-Za-z0-9+_-]+\.[A-Za-z0-9+_-]+ ]]; then
  # This is for a website URL entered
  TempDomain=$(echo $1 | cut -c 5-);
  Domain=$(echo $TempDomain | grep -Eo "[A-Za-z0-9+_-]+\.[A-Za-z0-9+_-]+" );
elif [[ $1 =~ [A-Za-z0-9+_-]+\.[A-Za-z0-9+_-]+ ]]; then
  # if a domain is entered just keep the domain
  Domain=$1;
fi

#don't run with a wrong domain
if [[ -z "$Domain" ]]; then
  exit
fi

#now we have a Domain we can get the information needed and display it to the user:

#Getting the information needed
WHOISoutput=$(whois $Domain);
Digoutput=$(dig $Domain);

#What i am planning to show:
# 1) the Registrar and the Registrar Abuse Email -- so they can inform the Registrar that abuse is happening
# 2) Created/Changed date -- so they know how long the abuse has been going on, and how affective the domain is to inform those affected
# 3) Name/Organization (if any)/and Email of Registrant -- so you can know the potentual identity of one of the website abuser (if they used real information)
# 4) Name/Organization (if any)/and Email of Admin -- so you can know the potentual identity of one of the website abuser (if they used real information)
# 5) Name/Organization (if any)/and Email of Tech -- so you can know the potentual identity of one of the website abuser (if they used real information)
# 6) Name/Organization (if any)/and Email of billing person -- so you can know the potentual identity of one of the website abuser (if they used real information)
# 7) IP for the domain


# Getting all the display values:

#Registrant Information:
RName=$(echo $WHOISoutput | grep -Eo "Registrant Name: ([A-Za-z0-9 ]+)+" | head -1 | cut -c 17-);
ROrganization=$(echo $WHOISoutput | grep -Eo "Registrant Organization: ([A-Za-z0-9 ]+)+" | head -1 | cut -c 25-);
REmail=$(echo $WHOISoutput | grep -Eo "Registrant Email: [A-Za-z0-9]+@[A-Za-z0-9]+\.[A-Za-z0-9]+" | head -1 | awk -F' ' '{print $3}')

#Admin Information:
AName=$(echo $WHOISoutput | grep -Eo "Admin Name: ([A-Za-z0-9 ]+)+" | head -1 | cut -c 12-);
AOrganization=$(echo $WHOISoutput | grep -Eo "Admin Organization: ([A-Za-z0-9 ]+)+" | head -1 | cut -c 20-);
AEmail=$(echo $WHOISoutput | grep -Eo "Admin Email: [A-Za-z0-9]+@[A-Za-z0-9]+\.[A-Za-z0-9]+" | head -1 | awk -F' ' '{print $3}')

#Tech Information:
TName=$(echo $WHOISoutput | grep -Eo "Tech Name: ([A-Za-z0-9 ]+)+" | head -1 | cut -c 11-);
TOrganization=$(echo $WHOISoutput | grep -Eo "Tech Organization: ([A-Za-z0-9 ]+)+" | head -1 | cut -c 19-);
TEmail=$(echo $WHOISoutput | grep -Eo "Tech Email: [A-Za-z0-9]+@[A-Za-z0-9]+\.[A-Za-z0-9]+" | head -1 | awk -F' ' '{print $3}')

#Billing Information:
BName=$(echo $WHOISoutput | grep -Eo "Billing Name: ([A-Za-z0-9 ]+)+" | head -1 | cut -c 14-);
BOrganization=$(echo $WHOISoutput | grep -Eo "Billing Organization: ([A-Za-z0-9 ]+)+" | head -1 | cut -c 22-);
BEmail=$(echo $WHOISoutput | grep -Eo "Billing Email: [A-Za-z0-9]+@[A-Za-z0-9]+\.[A-Za-z0-9]+" | head -1 | awk -F' ' '{print $3}')

#dates:
CreationDate=$(echo $WHOISoutput | grep -Eo "Creation Date: [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]Z" | head -1 | awk -F' ' '{print $3}');
UpdatedDate=$(echo $WHOISoutput | grep -Eo "Updated Date: [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]Z" | head -1 | awk -F' ' '{print $3}');

#Registrar and the Registrar Abuse Email:
Registrar=$(echo $WHOISoutput | grep -Eo " Registrar: [A-Za-z0-9\.]+ " | head -1 | awk -F' ' '{print $2}');
Registrarabuseemail=$(echo $WHOISoutput | grep -Eo " Registrar Abuse Contact Email: [A-Za-z0-9]+@[A-Za-z0-9]+\.[A-Za-z0-9]+" | head -1 | awk -F' ' '{print $5}');

#Getting the IP for the domain
IPsbeforeedit=$(echo $Digoutput | awk -F';;' '{print $8}' | grep -Eo "([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])");

IPoutput=$(echo $IPsbeforeedit | awk '{print $0}');

#Getting all the servers connected to the domain:
#Servers=$(echo $Digoutput | awk -F';;' '{print $9}');

#echo "$Servers"

# Displaying the values to the analyst:
echo "\nInformation for:                    $Domain\n"
#border for visual difference in output to other commands so user can easily see what is gotten from search
echo "-----------------------------------------------------------------"

echo "the Registrar is:                   $Registrar"
echo "the Registrar email for abuse is:   $Registrarabuseemail"

echo "Creation date for the domain:       $CreationDate"
echo "Domain Updated on:                  $UpdatedDate"

if [[ ! -z "$RName" ]]; then
  echo "Registrant Name:                   $RName"
else
  echo "Registrant Name:                   not recorded"
fi

if [[ ! -z "$ROrganization" ]]; then
  echo "Registrant Organization:           $ROrganization"
else
  echo "Registrant Organization:            not recorded"
fi

if [[ ! -z "$REmail" ]]; then
  echo "Registrant Email:                   $REmail"
else
  echo "Registrant Email:                   not recorded"
fi

if [[ ! -z "$AName" ]]; then
  echo "Admin Name:                        $AName"
else
  echo "Admin Name:                        not recorded"
fi

if [[ ! -z "$AOrganization" ]]; then
  echo "Admin Organization:                $AOrganization"
else
  echo "Admin Organization:                 not recorded"
fi

if [[ ! -z "$AEmail" ]]; then
  echo "Admin Email:                        $AEmail"
else
  echo "Admin Email:                        not recorded"
fi

if [[ ! -z "$TName" ]]; then
  echo "Tech Name:                         $TName"
else
  echo "Tech Name:                         not recorded"
fi

if [[ ! -z "$TOrganization" ]]; then
  echo "Tech Organization:                 $TOrganization"
else
  echo "Tech Organization:                  not recorded"
fi

if [[ ! -z "$TEmail" ]]; then
  echo "Tech Email:                         $TEmail"
else
  echo "Tech Email:                         not recorded"
fi

if [[ ! -z "$BName" ]]; then
  echo "Billing Name:                      $BName"
else
  echo "Billing Name:                       not recorded"
fi

if [[ ! -z "$BOrganization" ]]; then
  echo "Billing Organization:              $BOrganization"
else
  echo "Billing Organization:               not recorded"
fi

if [[ ! -z "$BEmail" ]]; then
  echo "Billing Email:                      $BEmail"
else
  echo "Billing Email:                      not recorded"
fi

echo "The IPs of the domain are:          $IPoutput"
echo "-----------------------------------------------------------------"

#Examples of Output for big URLs

#Information for:                    cnn.com

#-----------------------------------------------------------------
#the Registrar is:                   CSC
#the Registrar email for abuse is:   domainabuse@cscglobal.com
#Creation date for the domain:       1993-09-22T04:00:00Z
#Domain Updated on:                  2018-04-10T16:43:38Z
#Registrant Name:                    Domain Name Manager Registrant Organization
#Registrant Organization:            Turner Broadcasting System
#Registrant Email:                   tmgroup@turner.com
#Admin Name:                         Domain Name Manager Admin Organization
#Admin Organization:                 Turner Broadcasting System
#Admin Email:                        tmgroup@turner.com
#Tech Name:                          TBS Server Operations Tech Organization
#Tech Organization:                  Turner Broadcasting System
#Tech Email:                         hostmaster@turner.com
#Billing Name:                       not recorded
#Billing Organization:               not recorded
#Billing Email:                      not recorded
#The IPs of the domain are:          151.101.65.67 151.101.1.67 151.101.193.67 151.101.129.67
#-----------------------------------------------------------------

#Information for:                    yahoo.ca

#-----------------------------------------------------------------
#the Registrar is:                   MarkMonitor
#the Registrar email for abuse is:   abusecomplaints@markmonitor.com
#Creation date for the domain:       2000-10-04T00:08:36Z
#Domain Updated on:                  2021-11-10T20:44:58Z
#Registrant Name:                    Yahoo Canada Corp
#Registrant Organization:            not recorded
#Registrant Email:                   domainip@yahooinc.com
#Admin Name:                         Andres Lorca
#Admin Organization:                 Yahoo Canada Corp
#Admin Email:                        domainip@yahooinc.com
#Tech Name:                          Andres Lorca
#Tech Organization:                  Yahoo Canada Corp
#Tech Email:                         domainip@yahooinc.com
#Billing Name:                       CCOPS Billing
#Billing Organization:               MarkMonitor Inc
#Billing Email:                      ccopsbilling@markmonitor.com
#The IPs of the domain are:          212.82.100.150 74.6.136.150 98.136.103.23
#-----------------------------------------------------------------

#Information for:                    uvic.ca

#-----------------------------------------------------------------
#the Registrar is:                   Webnames.ca
#the Registrar email for abuse is:   garrett@webnames.ca
#Creation date for the domain:       2000-10-02T20:46:49Z
#Domain Updated on:                  2022-01-21T16:01:04Z
#Registrant Name:                    University of Victoria
#Registrant Organization:            not recorded
#Registrant Email:                   rkozsan@uvic.ca
#Admin Name:                         Jane Godfrey
#Admin Organization:                 University of Victoria
#Admin Email:                        jgodfrey@uvic.ca
#Tech Name:                          UVic NOC
#Tech Organization:                  University of Victoria
#Tech Email:                         netadmin@uvic.ca
#Billing Name:                       not recorded
#Billing Organization:               not recorded
#Billing Email:                      not recorded
#The IPs of the domain are:          142.104.197.120
#-----------------------------------------------------------------
