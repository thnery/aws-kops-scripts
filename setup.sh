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

echo "> Installing cert-manager"
kubectl apply -f cert-manager/

echo "> Installing clusterissuer"
kubectl apply -f clusterissuers/

echo "> Creating certificates"
kubectl apply -f certificates/

echo "> Creating ingresses"
kubectl apply -f ingresses/
