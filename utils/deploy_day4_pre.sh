#!/bin/sh

Q='Resources
| where type =~ "Microsoft.ContainerService/managedClusters"
| where resourceGroup startswith "aksWorkshopRG-"'

az graph query -q "$Q" --query "data[].[name,resourceGroup]" -o tsv \
| xargs -n 2 sh -c 'az aks get-credentials -n $0 -g $1 \
&& kubectl apply -k k8s/nginx/overlays/day4'
