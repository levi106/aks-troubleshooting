#!/bin/sh

Q='Resources
| where type =~ "Microsoft.ContainerService/managedClusters"
| where resourceGroup startswith "aksWorkshopRG-"'

az config set extension.use_dynamic_install=yes_without_prompt
az graph query -q "$Q" --query "data[].[name,resourceGroup]" -o tsv \
| xargs -n 2 sh -c 'az aks start -n $0 -g $1 --no-wait'
