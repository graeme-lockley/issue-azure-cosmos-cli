#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export RG_NAME=test
export DB_ACCOUNT_NAME=test2db
export DB_DATABASE_NAME=TestDatabase
export DB_CONTAINER_NAME=TestContainer

echo "----| Determine logged in user's Object Id"
USER_OBJECT_ID=$( az ad signed-in-user show --only-show-errors --query "id" --output tsv || exit 1 )

echo "----| Create Resource Group: $RG_NAME"
az group create \
    --name "$RG_NAME" \
    --location "centralus" || exit 1

echo "----| Create cosmos account: $DB_ACCOUNT_NAME"
az cosmosdb create \
    --name "$DB_ACCOUNT_NAME" \
    --resource-group "$RG_NAME" \
    --locations "regionName=westus" || exit 1

echo "----| Create account in database: $DB_ACCOUNT_NAME"
az cosmosdb sql database create \
    --name "$DB_DATABASE_NAME" \
    --account-name "$DB_ACCOUNT_NAME" \
    --resource-group "$RG_NAME" || exit 1

echo "----| Create container in database: $DB_CONTAINER_NAME"
az cosmosdb sql container create \
    --name "$DB_CONTAINER_NAME" \
    --database-name "$DB_DATABASE_NAME" \
    --account-name "$DB_ACCOUNT_NAME" \
    --resource-group "$RG_NAME" \
    --partition-key-path "/LastName" || exit 1

echo "----| Create role \"CLIRole\""
az cosmosdb sql role definition create \
    --account-name "$DB_ACCOUNT_NAME" \
    --resource-group "$RG_NAME" \
    --body @"$SCRIPT_DIR/CLIRole.json" || exit 1

CLI_ROLE_ID=$( az cosmosdb sql role definition list --account-name "$DB_ACCOUNT_NAME" --resource-group "$RG_NAME" --query "[?roleName=='CLIRole']".name --output tsv )

echo "----| Assign role \"CLIRole\" ($CLI_ROLE_ID) to $USER_OBJECT_ID"
az cosmosdb sql role assignment create \
    --account-name "$DB_ACCOUNT_NAME" \
    --resource-group "$RG_NAME" \
    --scope "/" \
    --principal-id "$USER_OBJECT_ID" \
    --role-definition-id "$CLI_ROLE_ID"
