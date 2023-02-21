#!/bin/sh

Q='Resources
| where type =~ "Microsoft.ContainerService/managedClusters"
| where resourceGroup startswith "aksWorkshopRG-"'

helm repo add chaos-mesh https://charts.chaos-mesh.org
helm repo update

az graph query -q "$Q" --query "data[].[name,resourceGroup]" -o tsv \
| xargs -n 2 sh -c '&& az aks get-credentials -n $0 -g $1 \
&& kubectl create ns chaos-testing \
&& helm install chaos-mesh chaos-mesh/chaos-mesh --namespace chaos-testing --set chaosDaemon.runtime=containerd --set chaosDaemon.socketPath=/run/containerd/containerd.sock'
