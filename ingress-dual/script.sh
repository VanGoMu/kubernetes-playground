#!/bin/bash

echo -e "\e[36mDesplegando nginx controller front...\e[0m"
helm install ingress-nginx-front ingress-nginx/ingress-nginx \
  --namespace ingress-nginx-front \
  --create-namespace \
  -f front-ingress-controller-values.yaml

echo -e "\e[36mDesplegando nginx controller back...\e[0m"
helm install ingress-nginx-back ingress-nginx/ingress-nginx \
  --namespace ingress-nginx-back \
  --create-namespace \
  -f back-ingress-controller-values.yaml

echo -e "\e[36mVerificando los controladores de ingress...\e[0m"
kubectl get pods -n ingress-nginx-front
kubectl get pods -n ingress-nginx-back

echo -e "\e[36mVerificando los servicios...\e[0m"
kubectl get svc -n ingress-nginx-front
kubectl get svc -n ingress-nginx-back

echo -e "\e[36mDesplegando la ingress intermedio...\e[0m"
kubectl apply -f ingress-redirect.yml

echo -e "\e[36mVerificando los endpoints...\e[0m"
kubectl describe ingress front-ingress -n ingress-nginx-front

echo -e "\e[36mDesplegando la aplicación de ejemplo...\e[0m"
kubectl apply -f example-app-rewrite.yaml

echo -e "\e[36mVerificando los ingress...\e[0m"
kubectl get ingress --all-namespaces

# Si no hay load balancer, añadir entrada en /etc/hosts para pruebas..."
# echo "<host_ip> app.local" | sudo tee -a /etc/hosts

# echo "Probando el acceso a la aplicación a través de la cadena de ingress..."
curl -v http://app.local:31080/prefix/test