#!/bin/bash
#
# This script starts the JBoss BusinessDay OpenShift in action Demo
#
#

usage() {
        echo "Usage: $0 <OPENSHIFT_MASTER_URL> <PROJECTNAME> <PATH_TO_YOUR_CLONED_REPO> <EAP_OR_WILDFLY>"
}

if [ -z "$1" ]; then
        echo "The OpenShift-Master-URL is empty and has to be set!"
        usage
        exit 1;
fi

if [ -z "$2" ]; then
        echo "You have to define a Projectname "
        usage
        exit 1;
fi

if [ -z "$3" ]; then
        echo "You have to define the path to your cloned repo"
        usage
        exit 1;
fi

if [ -z "$4" ]; then
        echo "You have to define the version! 'eap' or 'wildfly'"
        usage
        exit 1;
fi

if [ "$4" = "eap" ]; then
        EAP_OR_WILDFLY='mlbparks-template-eap.json'
        TEMPLATE='mlbparks-eap'
fi

if [ "$4" = "wildfly" ]; then
        EAP_OR_WILDFLY='mlbparks-template-wildfly.json'
        TEMPLATE='mlbparks-wildfly'
fi

OPENSHIFT_MASTER_URL=$1
PROJECTNAME=$2
PATH_TO_YOUR_CLONED_REPO=$3


echo ""
echo "####################################################################"
echo "##################### Starting Demo  ###############################"
echo "####################################################################"


read -p 'Press <Return> to continue, <Ctrl-c> to cancel' -n 1 -r

echo "####################################################################"
echo "###################### OpenShift login  ############################"
echo "####################################################################"

oc login ${masterUrl}

echo ""
echo ""

read -p 'Creating project "'${PROJECTNAME}'" and switch to it. Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r

echo ""
echo ""
echo "####################################################################"
echo "####################### Creating the new Project  ##################"
echo "####################################################################"

oc new-project ${PROJECTNAME}

echo ""
echo ""
echo "####################################################################"
echo "####################### Presentation time!  ########################"
echo "####################################################################"

read -p 'Did you explain "Source to Image"? Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r
read -p 'Would you like to create the "MLB Parks" template? Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r

echo ""
echo ""
echo "####################################################################"
echo "#############  Creating template '${EAP_OR_WILDFLY}' #########"
echo "####################################################################"

oc create -f ${EAP_OR_WILDFLY}

read -p 'Would you like to process the "MLB Parks" template? Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r

echo ""
echo ""
echo "####################################################################"
echo "#############  Processing template '${TEMPLATE}' #########"
echo "####################################################################"

oc new-app --template=${TEMPLATE}

echo ""
echo ""
echo "####################################################################"
echo "########################## Logging out #############################"
echo "####################################################################"

oc logout

echo "Finished"
