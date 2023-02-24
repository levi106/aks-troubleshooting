#!/bin/bash

Q='Resources
| where type =~ "Microsoft.Insights/webtests"
| where resourceGroup startswith "aksWorkshopRG-"'

az graph query -q "$Q" --query "data[].[name,resourceGroup]" -o tsv \
| xargs -n 2 sh -c 'az monitor app-insights web-test update -n $0 -g $1 --enabled true --no-wait'