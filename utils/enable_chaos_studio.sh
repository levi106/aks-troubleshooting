#!/bin/sh

Q='Resources
| where type =~ "Microsoft.ContainerService/managedClusters"
| where resourceGroup startswith "aksWorkshopRG-"'

az graph query -q "$Q" --query "data[].id" -o tsv \
| xargs -n 1 sh -c 'az rest --method put --url "https://management.azure.com/$0/providers/Microsoft.Chaos/targets/Microsoft-AzureKubernetesServiceChaosMesh?api-version=2021-09-15-preview" --body "{\"properties\":{}}" \
&& az rest --method put --url "https://management.azure.com/$0/providers/Microsoft.Chaos/targets/Microsoft-AzureKubernetesServiceChaosMesh/capabilities/PodChaos-2.1?api-version=2021-09-15-preview"  --body "{\"properties\":{}}"'
