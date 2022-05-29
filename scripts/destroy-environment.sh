#!/usr/bin/env bash

export RG_NAME=test

echo "----| Delete Resource Group: $RG_NAME"
az group delete \
    --name="$RG_NAME" \
    --yes \
    --no-wait
