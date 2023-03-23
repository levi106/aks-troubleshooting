#!/bin/bash

if [ $# -ne 3 ]; then
  echo ./update_webtest_target_ips.sh "Location" "Num of users" "Namespace"
  exit 1
fi

DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "[" > serviceIPs.json

N=$(expr ${2} - 1)
for ((i=0;i<N;++i))
do
    echo -n \" >> serviceIPs.json
    echo -n $(az graph query -q "Resources | where type =~ 'Microsoft.Network/publicIPAddresses' | where resourceGroup startswith 'mc_aksworkshoprg-user${i}_' | where tags['k8s-azure-service'] =~ '${3}/webapp'" --query "data[].properties.ipAddress" -o tsv) >> serviceIPs.json
    echo \", >> serviceIPs.json
done
echo -n \" >> serviceIPs.json
echo -n $(az graph query -q "Resources | where type =~ 'Microsoft.Network/publicIPAddresses' | where resourceGroup startswith 'mc_aksworkshoprg-user${N}_' | where tags['k8s-azure-service'] =~ '${3}/webapp'" --query "data[].properties.ipAddress" -o tsv) >> serviceIPs.json
echo \" >> serviceIPs.json
echo "]" >> serviceIPs.json

az deployment sub create -l ${1} \
    --name aksWorkshopWebTestSettings \
    --template-file=${DIR}/../bicep/webtest.bicep \
    --parameters serviceIPs=@serviceIPs.json \
    --parameters numOfUsers=${2}