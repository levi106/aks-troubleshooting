#!/bin/bash

if [ $# -ne 1 ]; then
  echo ./delete_web_app "Layer name"
  exit 1
fi

DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
export LAYER=${1}

Q='Resources
| where type =~ "Microsoft.ContainerService/managedClusters"
| where resourceGroup startswith "aksWorkshopRG-"'

touch ${DIR}/../k8s/web_app/overlays/${LAYER}/.env.ai
touch ${DIR}/../k8s/web_app/overlays/${LAYER}/.env.db

az graph query -q "$Q" --query "data[].[name,resourceGroup]" -o tsv \
| xargs -n 2 sh -c 'az aks get-credentials -n $0 -g $1 \
&& kubectl delete -k ${DIR}/../k8s/web_app/overlays/${LAYER}'
