#!/usr/bin/env bash
set -euo pipefail
: "${ARM_CLIENT_ID:?}" "${ARM_CLIENT_SECRET:?}" "${ARM_TENANT_ID:?}" "${ARM_SUBSCRIPTION_ID:?}"
az login --service-principal --username "$ARM_CLIENT_ID" --password "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID" --output none
az account set --subscription "$ARM_SUBSCRIPTION_ID"
