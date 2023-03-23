#!/bin/bash

Q='Resources
| where type =~ "Microsoft.Compute/virtualMachineScaleSets"
| where resourceGroup startswith "MC_aksWorkshopRG-user"'

az graph query -q "$Q" --query "data[].[name,resourceGroup]" -o tsv \
| xargs -n 2 sh -c 'az vmss run-command invoke -g $1 -n $0 --command-id RunShellScript --scripts "sudo systemctl stop kubelet" --instance-id $(az vmss list-instances -g $1 -n $0 --query "[0].instanceId" -o tsv)'
