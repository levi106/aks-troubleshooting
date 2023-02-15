#!/bin/bash

Q='ResourceContainers
| where type =~ "microsoft.resources/subscriptions/resourcegroups"
| where name startswith "aksWorkshopRG-user"
| project name'

az graph query -q "$Q" --query "data[].name" -o tsv \
| xargs -i az group delete --yes -n {}
