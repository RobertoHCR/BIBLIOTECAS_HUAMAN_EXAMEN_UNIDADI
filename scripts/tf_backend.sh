#!/usr/bin/env bash
set -euo pipefail
: "${PROJECT_SUFFIX:?}" "${AZURE_LOCATION:?}"
if [[ ! "$PROJECT_SUFFIX" =~ ^[a-z0-9]{6,12}$ ]]; then echo 'Sufijo inválido'; exit 1; fi
STATE_RG="rg-bnp-state-$PROJECT_SUFFIX"
STATE_ACCOUNT="stbnp$PROJECT_SUFFIX"
if ! az group show --name "$STATE_RG" --output none 2>/dev/null; then
  az group create --name "$STATE_RG" --location "$AZURE_LOCATION" --output none
fi
if ! az storage account show --name "$STATE_ACCOUNT" --resource-group "$STATE_RG" --output none 2>/dev/null; then
  az storage account create --name "$STATE_ACCOUNT" --resource-group "$STATE_RG" --location "$AZURE_LOCATION" --sku Standard_LRS --min-tls-version TLS1_2 --allow-blob-public-access false --output none
fi
STATE_KEY=$(az storage account keys list --account-name "$STATE_ACCOUNT" --resource-group "$STATE_RG" --query '[0].value' --output tsv)
echo "::add-mask::$STATE_KEY"
export AZURE_STORAGE_KEY="$STATE_KEY"
export ARM_ACCESS_KEY="$STATE_KEY"
az storage container create --name tfstate --account-name "$STATE_ACCOUNT" --output none
terraform -chdir=infra init -input=false -backend-config="resource_group_name=$STATE_RG" -backend-config="storage_account_name=$STATE_ACCOUNT" -backend-config="container_name=tfstate" -backend-config="key=bnp.tfstate"
# Solo disponible para pasos siguientes en este job; GitHub enmascara el valor.
printf 'ARM_ACCESS_KEY=%s\n' "$STATE_KEY" >> "$GITHUB_ENV"
