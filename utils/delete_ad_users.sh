#!/bin/bash

if [ $# -ne 2 ]; then
  echo ./delete_ad_users.sh "<num of users>" "<tenant name>"
  exit 1
fi

for (( i=0; i<$1; i++ ))
do
  az ad user delete --id labuser$i@$2
done
