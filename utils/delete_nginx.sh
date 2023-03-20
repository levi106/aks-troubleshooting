#!/bin/sh

if [ $# -ne 1 ]; then
  echo ./deploy_nginx.sh "overlay path"
  exit 1
fi

export layer=$1

Q='Resources
| where type =~ "Microsoft.ContainerService/managedClusters"
| where resourceGroup startswith "aksWorkshopRG-"'

az graph query -q "$Q" --query "data[].[name,resourceGroup]" -o tsv \
| xargs -n 2 sh -c 'az aks get-credentials -n $0 -g $1 \
&& kubectl delete -k k8s/nginx/overlays/${layer}'
