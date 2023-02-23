#!/bin/bash

echo "[" > serviceIPs.json
numOfUsers=2
for ((i=0;i<$numOfUsers;++i))
do
    echo $i
    echo -n \" >> serviceIPs.json
    echo -n $(az graph query -q "Resources | where type =~ 'Microsoft.Network/publicIPAddresses' | where resourceGroup startswith 'mc_aksworkshoprg-user${i}_' | where tags['k8s-azure-service'] =~ 'day2/webapp'" --query "data[].id" -o tsv) >> serviceIPs.json
    echo \", >> serviceIPs.json
done
echo -n \" >> serviceIPs.json
echo -n $(az graph query -q "Resources | where type =~ 'Microsoft.Network/publicIPAddresses' | where resourceGroup startswith 'mc_aksworkshoprg-user${numOfUsers}_' | where tags['k8s-azure-service'] =~ 'day2/webapp'" --query "data[].id" -o tsv) >> serviceIPs.json
echo \" >> serviceIPs.json
echo "]" >> serviceIPs.json
