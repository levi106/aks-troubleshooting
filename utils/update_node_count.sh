#!/bin/sh

if [ $# -ne 1 ]; then
  echo ./update_node_count.sh "node count"
  exit 1
fi

NodeCount=$1
Q='Resources
| where type =~ "Microsoft.ContainerService/managedClusters"
| where resourceGroup startswith "aksWorkshopRG-"'

az config set extension.use_dynamic_install=yes_without_prompt
az graph query -q "$Q" --query "data[].[name,resourceGroup]" -o tsv \
| xargs -n 2 sh -c 'az aks nodepool scale --cluster-name $0 -g $1 -n systempool --no-wait --node-count $NodeCount'
