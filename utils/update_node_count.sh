#!/bin/bassh

if [ $# -ne 1 ]; then
  echo ./update_node_count.sh "Node count"
  exit 1
fi

export NodeCount=$1
Q='Resources
| where type =~ "Microsoft.ContainerService/managedClusters"
| where resourceGroup startswith "aksWorkshopRG-"'

az graph query -q "$Q" --query "data[].[name,resourceGroup]" -o tsv \
| xargs -n 2 sh -c 'az aks nodepool scale --cluster-name $0 -g $1 -n systempool --node-count $NodeCount'
