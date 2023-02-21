#!/bin/sh

Q='Resources
| where type =~ "Microsoft.ContainerService/managedClusters"
| where resourceGroup startswith "aksWorkshopRG-"'