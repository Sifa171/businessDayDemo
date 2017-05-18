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

cd ${PATH_TO_YOUR_CLONED_REPO}

read -p 'Press <Return> to continue, <Ctrl-c> to cancel' -n 1 -r

echo "####################################################################"
echo "###################### OpenShift login  ############################"
echo "####################################################################"

oc login ${OPENSHIFT_MASTER_URL}

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

read -p 'Did you explain the template? Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r
read -p 'Would you like to process the "MLB Parks" template? Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r

echo ""
echo ""
echo "####################################################################"
echo "#############  Processing template '${TEMPLATE}' #########"
echo "####################################################################"

oc new-app --template=${TEMPLATE}

read -p 'Would you like to follow the buildlogs? Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r

echo ""
echo ""
echo "####################################################################"
echo "#############  Following Buildlogs  ################################"
echo "####################################################################"

BUILDLOGS=$(oc get pods | grep -i build | awk '{print $1}')
echo ${BUILDLOGS}
oc logs -f ${BUILDLOGS}

read -p 'Would you like to influence the buildprocess? Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r

echo ""
echo ""
echo "####################################################################"
echo "#############  Creating assemble script and starting a new build  ##"
echo "####################################################################"

mkdir -p .s2i/bin
cp misc/scripts/assemble .s2i/bin/
oc start-build mlbparks --follow

read -p 'Would you like to define healt checks? Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r

echo ""
echo ""
echo "####################################################################"
echo "#############  Defining health checks  #############################"
echo "####################################################################"

oc replace -f misc/scripts/dc-with-health-checks.yaml

read -p 'Did you explain health checks? Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r

echo ""
echo ""
echo "####################################################################"
echo "#############  It is time for the docker strategy  ######## ########"
echo "####################################################################"

read -p 'Would you like to create an ImageStream and a BuildConfig? Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r

echo ""
echo ""
echo "####################################################################"
echo "############## Creating ImageStream and BuildConfig ################"
echo "####################################################################"

oc create -f misc/scripts/is-analyze-image.yaml
oc create -f misc/scripts/bc-analyze-image.yaml

read -p 'Would you like to start the dockerbuild? Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r

echo ""
echo ""
echo "####################################################################"
echo "############## Starting Dockerbuild ################################"
echo "####################################################################"

oc start-build analyze --follow

read -p 'Would you like to run the analye image? Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r

echo ""
echo ""
echo "####################################################################"
echo "############## Starting analyze container ##########################"
echo "####################################################################"

IMAGE_REGISTRY_IP=$(oc get svc -n default | awk '{if ($1 == "docker-registry") print $2;}')
oc run analyze -it --image=${IMAGE_REGISTRY_IP}/${PROJECTNAME}/analyze --restart=Always

read -p 'Would you like to show some deployment strategies? Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r
read -p 'Did you explain "recreate"? Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r

echo ""
echo ""
echo "####################################################################"
echo "############## Changing to rolling upgrade #########################"
echo "####################################################################"

oc replace -f misc/scripts/dc-with-rolling-upgrade.yaml

read -p 'Did you explain deployment strategies? Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r
read -p 'Would you like to show what config maps do? Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r


echo ""
echo ""
echo "####################################################################"
echo "############## Creating Config-Map and deploy ######################"
echo "####################################################################"

oc create -f misc/scripts/config-map.yaml
oc replace -f misc/scripts/dc-with-config-map.yaml

read -p 'Did you show the new ENVs? Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r
read -p 'Would you like to show what secrets do? Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r

echo ""
echo ""
echo "####################################################################"
echo "############## Creating secrets and deploy ######################"
echo "####################################################################"

oc create secret generic my-secret --from-file=misc/scripts/testfileforsecret.md
oc replace -f misc/scripts/dc-with-secrets.yaml

read -p 'Did you show the POD crahses? Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r
read -p 'Would you like to show what happens if a health check fails? Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r

echo ""
echo ""
echo "####################################################################"
echo "############## Creating health checks with failures  and deploy ####"
echo "####################################################################"

oc replace -f misc/scripts/dc-with-failures.yaml

read -p 'Did you show the EFK? Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r
read -p 'Did you show the JBoss Tools? Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r
read -p 'Did you show "oc cluster up"? Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r
read -p 'Did you show MiniShift? Press <return> to continue, <Ctrl-c> to cancel' -n 1 -r

echo ""
echo ""
echo "####################################################################"
echo "########################## Shutting down demo ######################"
echo "####################################################################"

oc logout

echo ""
echo ""
echo "####################################################################"
echo "########################## Finished ################################"
echo "####################################################################"
