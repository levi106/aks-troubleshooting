#!/bin/bash

if [ $# -ne 3 ]; then
  echo ./create_ad_users.sh "<num of users>" "<password>" "<tenant name>"
  exit 1
fi

for (( i=0; i<$1; i++ ))
do
  az ad user create --display-name labuser$i --password $2 --user-principal-name labuser$i@$3
done
