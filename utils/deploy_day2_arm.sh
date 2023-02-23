#!/bin/sh

if [ $# -ne 2 ]; then
  echo ./deploy_day2_arm.sh "Location" "VM Count"
  exit 1
fi

Q='Resources
| where type =~ "Microsoft.Network/publicIPAddresses"
| where resourceGroup startswith "MC_aksWorkshopRG-"
| where tags["k8s-azure-service"] =~ "day2/webapp"
| project id'

serviceIPs=$(az graph query -q "$Q" --query "data[].id" -o json)

az deployment sub create -l $0 \
    --name aksWorkshopDeploymentDay2 \
    --template-file=../bicep/day2.bicep \
    --parameters serviceIPs=$serviceIPs \
    --parameters numOfUsers=$1