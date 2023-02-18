#!/bin/sh

if [ $# -ne 1 ]; then
  echo ./deploy_day1.sh "SQL Admin password"
  exit 1
fi

Q='Resources
| where type =~ "Microsoft.ContainerService/managedClusters"
| where resourceGroup startswith "aksWorkshopRG-"'

serverName=$(az sql server list -g aksWorkshopRG --query "[].name" --output tsv)
dbName=$(az sql db list -g aksWorkshopRG -s ${serverName} --query "[].name" --output tsv | grep "db-")
echo -n "jdbc:sqlserver://${serverName}.database.windows.net:1433;database=${dbName};user=sqladmin@${serverName};password=${1};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=15;socketTimeout=30000;connectRetryCount=0" > k8s/db_job/overlays/day1/db.txt

az graph query -q "$Q" --query "data[].[name,resourceGroup]" -o tsv \
| xargs -n 2 sh -c 'echo $(az monitor app-insights component show -g $1 --query "[0].connectionString" -o tsv) > k8s/db_job/overlays/day1/ai.txt \
&& az aks get-credentials -n $0 -g $1 \
&& kubectl apply -k k8s/db_job/overlays/day1'
