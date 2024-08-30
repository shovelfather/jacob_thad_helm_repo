#!/usr/bin/env bash

#################
#
# This script spits out a values.yaml
# file for our standard training kit
# in microk8s.  It assumes and checks
# for the customer specific git repo
# where all config is expected to be
# stored.
#
#################

# WARN: Ignoring this for local testing purposes. Uncomment at your own risk, if needed.
# echo Checking Paths.
# if [ -d /opt/helm/customers ]; then
# 	echo "Customers Git Repo appears to exist."
# else
# 	echo "No customer folder found.  It should be checked out from eir or it can be faked by creating /opt/helm/customers/"
# 	exit 5
# fi

if [ ! -d "../customer_values" ]; then
	echo "creating customer_values directory"
fi

printf "Creating a new Training Instance\n\n"
printf "Enter Instance Name: "
read -r instanceName
printf '\n\nYou entered %s, url will be: %s.billk8s.decisions.com\n' "${instanceName}" "${instanceName}"
echo -n 'Enter Container Tag (Leave blank for latest): '
read -r tag
if [ -z "${tag}" ]; then tag="latest"; fi
echo -n "Enter Admin User Email to Create: "
read -r adminEmail
echo -n "Enter Admin User Password to Create: "
read -r adminPass

sqlScript="pg_creds_${instanceName}.sh"
cp pg_creds.sh "${sqlScript}" # so we always keep a master copy of the template
sed -i "s/{ADMIN_EMAIL}/${adminEmail}/" "${sqlScript}"
sed -i "s/{ADMIN_PASS}/${adminPass}/" "${sqlScript}"

# TODO make entrypoint for this script in postgres deployment, mount the volume.
# dockerentrypoint.d or something like that

valuesFile="${instanceName}.yaml"
valuesFileLocation="../customer_values/${valuesFile}"
cp "../values.yaml" "${valuesFileLocation}"
url="${instanceName}.billk8s.decisions.com"

# sed -i "s/\${PG_USER}/${pgUser}/" training/values.yaml
# sed -i "s/\${PG_DBNAME}/${pgDBName}/" $valuesFile #This should always be `decisions`
# sed -i "s/\${PG_PASS}/${pgPass}/" "${valuesFile}"
sed -i "s/\${CUSTOMER_ID}/${instanceName}/" "${valuesFile}"
sed -i "s/\${VERSION}/${tag}/" "${valuesFile}"
sed -i "s/\${ADMIN_EMAIL}/${adminEmail}/" "${valuesFile}"
sed -i "s/\${ADMIN_PASS}/${adminPass}/" "${valuesFile}"
echo "Writing url:  ${url}"
sed -i "s,\${HOST_VALUE},${url}," "$valuesFile"

mkdir /opt/helm/customers/"${instanceName}"
mv "${valuesFile}" /opt/helm/customers/"${instanceName}/"

printf "\r\n-- Values file Created and stored at: /opt/helm/customers/%s", "${instanceName}"
printf "\r\nRun helm install to spin up environment."
