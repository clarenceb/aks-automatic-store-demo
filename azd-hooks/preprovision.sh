#!/bin/bash

if ${AZURE_COSMOSDB_ACCOUNT_KIND} == "MongoDB" && ${DEPLOY_AZURE_WORKLOAD_IDENTITY} == "true"; then
  echo "Azure CosmosDB account kind cannot be MongoDB when deploying Azure Workload Identity"
  exit 1
fi

echo "Ensuring Azure CLI extensions and dependencies are installed"

az provider register --namespace "Microsoft.ContainerService"
while [[ $(az provider show --namespace "Microsoft.ContainerService" --query "registrationState" -o tsv) != "Registered" ]]; do
  echo "Waiting for Microsoft.ContainerService provider registration..."
  sleep 3
done

az feature register --namespace "Microsoft.ContainerService" --name "NetworkObservabilityPreview"
while [[ $(az feature show --namespace "Microsoft.ContainerService" --name "NetworkObservabilityPreview" --query "properties.state" -o tsv) != "Registered" ]]; do
  echo "Waiting for NetworkObservabilityPreview feature registration..."
  sleep 3
done

az feature register --namespace "Microsoft.ContainerService" --name "NodeOsUpgradeChannelPreview"
while [[ $(az feature show --namespace "Microsoft.ContainerService" --name "NodeOsUpgradeChannelPreview" --query "properties.state" -o tsv) != "Registered" ]]; do
  echo "Waiting for NodeOsUpgradeChannelPreview feature registration..."
  sleep 3
done

az feature register --namespace "Microsoft.ContainerService" --name "AzureMonitorMetricsControlPlanePreview"
while [[ $(az feature show --namespace "Microsoft.ContainerService" --name "AzureMonitorMetricsControlPlanePreview" --query "properties.state" -o tsv) != "Registered" ]]; do
  echo "Waiting for AzureMonitorMetricsControlPlanePreview feature registration..."
  sleep 3
done

az feature register --namespace "Microsoft.ContainerService" --name "EnableAPIServerVnetIntegrationPreview"
while [[ $(az feature show --namespace "Microsoft.ContainerService" --name "EnableAPIServerVnetIntegrationPreview" --query "properties.state" -o tsv) != "Registered" ]]; do
  echo "Waiting for EnableAPIServerVnetIntegrationPreview feature registration..."
  sleep 3
done

az feature register --namespace "Microsoft.ContainerService" --name "NRGLockdownPreview"
while [[ $(az feature show --namespace "Microsoft.ContainerService" --name "NRGLockdownPreview" --query "properties.state" -o tsv) != "Registered" ]]; do
  echo "Waiting for NRGLockdownPreview feature registration..."
  sleep 3
done

az feature register --namespace "Microsoft.ContainerService" --name "SafeguardsPreview"
while [[ $(az feature show --namespace "Microsoft.ContainerService" --name "SafeguardsPreview" --query "properties.state" -o tsv) != "Registered" ]]; do
  echo "Waiting for SafeguardsPreview feature registration..."
  sleep 3
done

az feature register --namespace "Microsoft.ContainerService" --name "NodeAutoProvisioningPreview"
while [[ $(az feature show --namespace "Microsoft.ContainerService" --name "NodeAutoProvisioningPreview" --query "properties.state" -o tsv) != "Registered" ]]; do
  echo "Waiting for NodeAutoProvisioningPreview feature registration..."
  sleep 3
done

az feature register --namespace "Microsoft.ContainerService" --name "DisableSSHPreview"
while [[ $(az feature show --namespace "Microsoft.ContainerService" --name "DisableSSHPreview" --query "properties.state" -o tsv) != "Registered" ]]; do
  echo "Waiting for DisableSSHPreview feature registration..."
  sleep 3
done

az feature register --namespace "Microsoft.ContainerService" --name "AutomaticSKUPreview"
while [[ $(az feature show --namespace "Microsoft.ContainerService" --name "AutomaticSKUPreview" --query "properties.state" -o tsv) != "Registered" ]]; do
  echo "Waiting for AutomaticSKUPreview feature registration..."
  sleep 3
done

# propagate the feature registrations
az provider register -n Microsoft.ContainerService

# add azure cli extensions
az extension add --upgrade --name aks-preview
az extension add --upgrade --name amg