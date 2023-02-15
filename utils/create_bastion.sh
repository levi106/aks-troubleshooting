#!/bin/bash

az config set extension.use_dynamic_install=yes_without_prompt
az network bastion create --sku Basic -n bastion --public-ip-address bastion -g aksWorkshopRG -l japaneast --vnet-name vnet
