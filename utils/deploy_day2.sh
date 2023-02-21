#!/bin/sh

if [ $# -ne 1 ]; then
  echo ./deploy_day2.sh "SQL Admin password"
  exit 1
fi

Q='Resources
| where type =~ "Microsoft.ContainerService/managedClusters"
| where resourceGroup startswith "aksWorkshopRG-"'

serverName=$(az sql server list -g aksWorkshopRG --query "[].name" --output tsv)
dbName=$(az sql db list -g aksWorkshopRG -s ${serverName} --query "[].name" --output tsv | grep "db-")
echo "url=jdbc:sqlserver://${serverName}.database.windows.net:1433;database=${dbName};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net" > k8s/web_app/overlays/day2/.env.db
echo "username=sqladmin@${serverName}" >> k8s/web_app/overlays/day2/.env.db
echo "password=${1}" >> k8s/web_app/overlays/day2/.env.db

az graph query -q "$Q" --query "data[].[name,resourceGroup]" -o tsv \
| xargs -n 2 sh -c 'echo connectionstring=$(az monitor app-insights component show -g $1 --query "[0].connectionString" -o tsv) > k8s/web_app/overlays/day2/.env.ai \
&& az aks get-credentials -n $0 -g $1 \
&& kubectl apply -k k8s/web_app/overlays/day2'
