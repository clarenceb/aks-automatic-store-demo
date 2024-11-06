# Kaito on CPU nodes

If you can't get GPU nodes, follow these steps to get KAITO working on CPU nodes (but it's very slow).

```sh
LOCATION=australiaeast
SYSTEM_VM_SIZE=Standard_D4s_v3
KAITO_CPU_VM_SIZE=Standard_D16s_v3
KAITO_MODEL=falcon-7b-instruct

az group create -n kaito -l $LOCATION

az aks create \
    -n kaito \
    -g kaito \
    --network-plugin azure \
    --network-plugin-mode overlay \
    --enable-managed-identity \
    -c 2 \
    --generate-ssh-keys \
    --node-vm-size $SYSTEM_VM_SIZE

az aks get-credentials -n kaito -g kaito
kubectl get nodes

helm repo add kaito https://azure.github.io/kaito/charts/kaito
helm repo update

helm install workspace kaito/workspace --create-namespace -n kaito-workspace

helm ls -A
kubectl get pods -n kaito-workspace

az aks nodepool add \
    -g kaito \
    -c 1 \
    --cluster-name kaito \
    -n kaitoinf \
    --node-vm-size $KAITO_CPU_VM_SIZE \
    --node-taints sku=gpu:NoSchedule \
    --labels apps=$KAITO_MODEL

kubectl create ns pets

kubectl apply -f workspaces/$KAITO_MODEL-cpu-only.yaml -n pets
kubectl describe pod -n pets $(kubectl get pod -n pets -l app=$KAITO_MODEL -o jsonpath="{.items[0].metadata.name}")

kubectl run -n pets -it --rm --restart=Never curl --image=curlimages/curl 2>/dev/null -- curl -sX POST http://$KAITO_MODEL-cpu-only/chat -H "accept: application/json" -H "Content-Type: application/json" -d "{\"prompt\":\"What is a kubernetes?\"}"
``