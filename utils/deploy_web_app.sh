#!/bin/bash

if [ $# -ne 2 ]; then
  echo ./deploy_web_app.sh "SQL Admin password" "Layer name"
  exit 1
fi

DIR="$( dirname -- $( realpath -- "${BASH_SOURCE[0]}" ) )"
export LAYER=${2}

Q='Resources
| where type =~ "Microsoft.ContainerService/managedClusters"
| where resourceGroup startswith "aksWorkshopRG-"'

serverName=$(az sql server list -g aksWorkshopRG --query "[].name" --output tsv)
dbName=$(az sql db list -g aksWorkshopRG -s ${serverName} --query "[].name" --output tsv | grep "db-")
echo "url=jdbc:sqlserver://${serverName}.database.windows.net:1433;database=${dbName};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net" > ${DIR}/../k8s/web_app/overlays/${LAYER}/.env.db
echo "username=sqladmin@${serverName}" >> ${DIR}/../k8s/web_app/overlays/${LAYER}/.env.db
echo "password=${1}" >> ${DIR}/../k8s/web_app/overlays/${LAYER}/.env.db

az graph query -q "$Q" --query "data[].[name,resourceGroup]" -o tsv \
| xargs -n 2 sh -c 'echo connectionstring=$(az monitor app-insights component show -g $1 --query "[0].connectionString" -o tsv) > ${DIR}/../k8s/web_app/overlays/${LAYER}/.env.ai \
&& az aks get-credentials -n $0 -g $1 \
&& kubectl apply -k ${DIR}/../k8s/web_app/overlays/${LAYER}'

