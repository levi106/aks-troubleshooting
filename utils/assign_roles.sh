#!/bin/bash

if [ $# -ne 2 ]; then
  echo ./assign_roles.sh "<num of users>" "<tenant name>"
  exit 1
fi

for (( i=0; i<$1; i++ ))
do
  U=$(az ad user show --id "labuser$i@$2" --query id --output tsv)
  az role assignment create \
    --assignee $U \
    --role "b24988ac-6180-42a0-ab88-20f7382dd24c" \
    --resource-group "aksWorkshopRG-user$i"
  az role assignment create \
    --assignee $U \
    --role "acdd72a7-3385-48ef-bd42-f606fba81ae7" \
    --resource-group "aksWorkshopRG"
  az role assignment create \
    --assignee $U \
    --role "acdd72a7-3385-48ef-bd42-f606fba81ae7" \
    --resource-group "MC_aksWorkshopRG-user${i}_aks-${i}_japaneast"
done
