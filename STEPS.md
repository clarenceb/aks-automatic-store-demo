# AKS Automatic version of AKS Store Demo Steps

AKS Automatic deployment for the [AKS Store Demo](https://github.com/Azure-Samples/aks-store-demo).  It includes steps to deploy KAITO with GPU or CPU (not recommended as it's slow) nodes for local inferencing, instead of Azure OpenAI.

KAITO CPU Steps: [workspaces/README.md](./[workspaces/README.md)

See also AKS deployment of KAITO with GPU: [https://github.com/clarenceb/aks-store-demo/blob/main/Demo-Steps.md](https://github.com/clarenceb/aks-store-demo/blob/main/Demo-Steps.md)

```sh
az login

# Linux/WSL2
export KUBECONFIG=$HOME/.kube/config
kubelogin convert-kubeconfig -l azurecli

# Windows
az aks get-credentials -n <cluster-name> -g <rg-name>
set KUBECONFIG=%USERPROFILE%\.kubeconfig
kubelogin convert-kubeconfig -l azurecli

# Common steps
azd env new

azd config set alpha.aks.helm on
azd env set DEPLOY_AZURE_OPENAI true
azd env set DEPLOY_AZURE_WORKLOAD_IDENTITY true
azd env set AKS_VMSS_SKU Standard_DS4_v2
azd env set DEPLOY_AZURE_OPENAI_DALL_E_MODEL true
azd env set DEPLOY_AZURE_SERVICE_BUS true
azd env set DEPLOY_AZURE_COSMOSDB true
azd env set AZURE_COSMOSDB_FAILOVER_LOCATION centralus
azd env set AZURE_COSMOSDB_ACCOUNT_KIND GlobalDocumentDB
azd env set DEPLOY_OBSERVABILITY_TOOLS true
azd env set AZURE_LOCATION eastus2
azd env set DEPLOY_AZURE_CONTAINER_REGISTRY false
azd env set BUILD_CONTAINERS false
azd env set AZURE_OPENAI_LOCATION swedencentral

azd up

kubectl get nodes
kubectl get pods -n pets

# (Re-)run just the deployment if you make app changes
azd deploy

# If there are pod errors...
kubectl delete -n pets $(kubectl get pod -l app=ai-service -n pets -o name)
kubectl delete -n pets $(kubectl get pod -l app=makeline-service -n pets -o name)

# ...then manually install helm chart
helm upgrade demo --install ./charts/aks-store-demo --values custom-values.yaml -n pets

# KAITO with GPU nodes
# Follow steps here: https://github.com/clarenceb/aks-store-demo/blob/main/Demo-Steps.md
LLM_ENDPOINT=workspace-falcon-7b-instruct

# or KAITO with CPU nodes only
kubectl apply -f workspaces/falcon-7b-instruct-cpu-only.yaml -n pets
kubectl apply -f workspaces/workspace-svc.yaml -n pets
LLM_ENDPOINT=workspace-falcon-7b-instruct-cpu-only

# or direct deployment without a KAITO Workspace
kubectl apply -f workspaces/workspace-svc -n pets
kubectl apply -f workspaces/deployment.yaml -n pets
LLM_ENDPOINT=workspace-falcon-7b-instruct-cpu-only

kubectl get pods -n pets
kubectl get nodes
kubectl describe node <node-name>

# Test local endpoint
kubectl run -n pets -it --rm --restart=Never curl --image=curlimages/curl 2>/dev/null -- curl -sX POST http://${LLM_ENDPOINT}/chat -H "accept: application/json" -H "Content-Type: application/json" -d "{\"prompt\":\"What is a kubernetes?\"}"

# Update the AI Service in AKS store to use the local llm
kubectl patch cm -n pets ai-service-configs --type="json" --patch-file ai-service-local-llm-cm.json
kubect get cm -n pets ai-service-configs -o yaml
kubectl delete $(kubectl get pod -n pets -l app=ai-service -n pets -o name) -n pets
kubectl get pod -n pets -l app=ai-service -n pets

# Revert the AI Service in AKS store back to Azure OpenAI
kubectl patch cm -n pets ai-service-configs --type="json" --patch-file ai-service-cm.json
kubect get cm -n pets ai-service-configs -o yaml
kubectl delete $(kubectl get pod -n pets -l app=ai-service -n pets -o name) -n pets
kubectl get pod -n pets -l app=ai-service -n pets
```
