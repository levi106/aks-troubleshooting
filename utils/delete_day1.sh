#!/bin/sh

Q='Resources
| where type =~ "Microsoft.ContainerService/managedClusters"
| where resourceGroup startswith "aksWorkshopRG-"'

touch k8s/db_job/overlays/day1/ai.txt
touch k8s/db_job/overlays/day1/db.txt

az graph query -q "$Q" --query "data[].[name,resourceGroup]" -o tsv \
| xargs -n 2 sh -c 'az aks get-credentials -n $0 -g $1 \
&& kubectl delete -k k8s/db_job/overlays/day1'
