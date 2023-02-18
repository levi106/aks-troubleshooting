#!/bin/sh

Q='Resources
| where type =~ "Microsoft.Compute/VirtualMachines"
| where resourceGroup startswith "aksWorkshopRG-"'

az config set extension.use_dynamic_install=yes_without_prompt
az vm stop --no-wait --ids $(az graph query -q "$Q" --query "data[].id" -o tsv)
