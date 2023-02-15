#!/bin/bash

az config set extension.use_dynamic_install=yes_without_prompt
az network bastion delete -n bastion -g aksWorkshopRG
