#!/bin/sh

Q='Resources
| where type =~ "Microsoft.ContainerService/managedClusters"
| where resourceGroup startswith "aksWorkshopRG-"'

touch k8s/web_app/overlays/day4/.env.ai
touch k8s/web_app/overlays/day4/.env.db

az graph query -q "$Q" --query "data[].[name,resourceGroup]" -o tsv \
| xargs -n 2 sh -c 'az aks get-credentials -n $0 -g $1 \
&& kubectl delete -k k8s/web_app/overlays/day4'
