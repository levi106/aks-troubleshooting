#!/bin/bash

if [ $# -ne 2 ]; then
  echo ./deploy_day4_arm.sh "LOCATION" "VMCOUNT"
  exit 1
fi

echo "[" > serviceIPs.json

N=$(expr ${2} - 1)
for ((i=0;i<N;++i))
do
    echo -n \" >> serviceIPs.json
    echo -n $(az graph query -q "Resources | where type =~ 'Microsoft.Network/publicIPAddresses' | where resourceGroup startswith 'mc_aksworkshoprg-user${i}_' | where tags['k8s-azure-service'] =~ 'day4/webapp'" --query "data[].properties.ipAddress" -o tsv) >> serviceIPs.json
    echo \", >> serviceIPs.json
done
echo -n \" >> serviceIPs.json
echo -n $(az graph query -q "Resources | where type =~ 'Microsoft.Network/publicIPAddresses' | where resourceGroup startswith 'mc_aksworkshoprg-user${N}_' | where tags['k8s-azure-service'] =~ 'day4/webapp'" --query "data[].properties.ipAddress" -o tsv) >> serviceIPs.json
echo \" >> serviceIPs.json
echo "]" >> serviceIPs.json

az deployment sub create -l ${1} \
    --name aksWorkshopDeploymentDay5 \
    --template-file=../bicep/day5.bicep \
    --parameters serviceIPs=@serviceIPs.json \
    --parameters numOfUsers=${2}