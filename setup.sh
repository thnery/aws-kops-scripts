#!/bin/bash

echo "> Creating namespaces"
kubectl apply -f namespaces/

echo "> Creating configmaps"
for envfile in $(ls envs); do
  APP=$(echo $envfile | cut -d. -f1)
  NS=$(echo $envfile | cut -d. -f2)
  kubectl -n "$NS" create configmap "$APP-cm" --from-env-file="envs/$envfile" --dry-run -o yaml | kubectl apply -f -
done

echo "> Creating ServiceAccount for tiller for RBAC"
kubectl create -f tiller/rbac-config.yaml

echo "> Installing ingress-nginx"
kubectl apply -f ingress-nginx/mandatory.yaml
kubectl apply -f ingress-nginx/service-l4.yaml
kubectl apply -f ingress-nginx/patch-configmap-l4.yaml

echo "> Installing cert-manager with Helm"
helm install --name cert-manager \
    --namespace ingress \
    --set ingressShim.defaultIssuerName=letsencrypt-prod \
    --set ingressShim.defaultIssuerKind=ClusterIssuer \
    stable/cert-manager

echo "> Installing clusterissuer"
kubectl apply -f clusterissuers/

echo "> Creating certificates"
kubectl apply -f certificates/

echo "> Creating ingresses"
kubectl apply -f ingresses/

echo "> Installing Cluster Autoscaler"
helm install --name cluster-autoscaler \
    --namespace kube-system \
    --set image.tag=v1.2.0 \
    --set autoDiscovery.clusterName=<my-cluster-name> \
    --set extraArgs.balance-similar-node-groups=false \
    --set extraArgs.expander=random \
    --set rbac.create=true \
    --set rbac.pspEnabled=true \
    --set awsRegion=us-east-1 \
    --set nodeSelector."node-role\.kubernetes\.io/master"="" \
    --set tolerations[0].effect=NoSchedule \
    --set tolerations[0].key=node-role.kubernetes.io/master \
    --set cloudProvider=aws \
    stable/cluster-autoscaler
