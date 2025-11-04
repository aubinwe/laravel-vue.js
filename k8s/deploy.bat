@echo off
echo Deploiement de l'application Gestion Notes sur Kubernetes...

echo 1. Application des secrets et configmaps...
kubectl apply -f secret.yaml
kubectl apply -f configmap.yaml

echo 2. Deploiement de MySQL...
kubectl apply -f mysql-deployment.yaml
kubectl apply -f mysql-service.yaml

echo 3. Attente du demarrage de MySQL...
timeout /t 30

echo 4. Deploiement du backend...
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml

echo 5. Deploiement du frontend...
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml

echo 6. Configuration de l'ingress...
kubectl apply -f ingress.yaml

echo 7. Verification du statut...
kubectl get pods
kubectl get services
kubectl get ingress

echo Deploiement termine!
echo Acces: http://localhost ou http://votre-ip-cluster