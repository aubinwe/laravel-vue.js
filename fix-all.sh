#!/bin/bash

echo "========================================="
echo "    SOLUTION COMPLETE - RESET TOTAL"
echo "========================================="

# 1. NETTOYAGE COMPLET
echo "=== NETTOYAGE COMPLET ==="
kubectl delete namespace gestion-notes --ignore-not-found=true
docker system prune -f
minikube delete 2>/dev/null || true

# 2. DEMARRAGE MINIKUBE PROPRE
echo "=== DEMARRAGE MINIKUBE ==="
minikube start --driver=docker --memory=4096 --cpus=2
eval $(minikube docker-env)

# 3. BUILD DES IMAGES DANS MINIKUBE
echo "=== BUILD DES IMAGES ==="
cd appNotes
docker build -t appnotes-backend:latest .
cd ../frontend
docker build -t appnotes-frontend:latest .
cd ..

# 4. VERIFICATION DES IMAGES
echo "=== VERIFICATION IMAGES ==="
docker images | grep appnotes

# 5. DEPLOIEMENT ETAPE PAR ETAPE
echo "=== DEPLOIEMENT ==="
kubectl create namespace gestion-notes

# ConfigMap et Secrets
kubectl create configmap app-config \
  --from-literal=DB_HOST=mysql-service \
  --from-literal=DB_PORT=3306 \
  --from-literal=DB_DATABASE=gestion_notes \
  --from-literal=DB_USERNAME=root \
  --from-literal=APP_ENV=production \
  --from-literal=APP_DEBUG=false \
  -n gestion-notes

kubectl create secret generic app-secrets \
  --from-literal=DB_PASSWORD=rootpassword \
  --from-literal=APP_KEY=base64:c/U/5irtBb+IP8MfGt+eAyRrrIpg/WxiV/gHCByUOGs= \
  -n gestion-notes

# MySQL
echo "Deploiement MySQL..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
  namespace: gestion-notes
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "rootpassword"
        - name: MYSQL_DATABASE
          value: "gestion_notes"
        ports:
        - containerPort: 3306
---
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
  namespace: gestion-notes
spec:
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
EOF

# Attendre MySQL
echo "Attente MySQL..."
kubectl wait --for=condition=ready pod -l app=mysql -n gestion-notes --timeout=300s

# Backend
echo "Deploiement Backend..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: gestion-notes
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: appnotes-backend:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 8000
        env:
        - name: DB_HOST
          value: "mysql-service"
        - name: DB_PORT
          value: "3306"
        - name: DB_DATABASE
          value: "gestion_notes"
        - name: DB_USERNAME
          value: "root"
        - name: DB_PASSWORD
          value: "rootpassword"
        - name: APP_KEY
          value: "base64:c/U/5irtBb+IP8MfGt+eAyRrrIpg/WxiV/gHCByUOGs="
        - name: APP_ENV
          value: "production"
        - name: APP_DEBUG
          value: "false"
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: gestion-notes
spec:
  selector:
    app: backend
  ports:
  - port: 8000
    targetPort: 8000
EOF

# Attendre Backend
echo "Attente Backend..."
kubectl wait --for=condition=ready pod -l app=backend -n gestion-notes --timeout=300s

# Frontend
echo "Deploiement Frontend..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: gestion-notes
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: appnotes-frontend:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: gestion-notes
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
  type: NodePort
EOF

# Attendre Frontend
echo "Attente Frontend..."
kubectl wait --for=condition=ready pod -l app=frontend -n gestion-notes --timeout=180s

# 6. VERIFICATION FINALE
echo "=== VERIFICATION ==="
kubectl get pods -n gestion-notes
kubectl get services -n gestion-notes

# 7. ACCES
echo ""
echo "========================================="
echo "           APPLICATION PRETE !"
echo "========================================="
echo ""
echo "URL d'accès:"
minikube service frontend-service -n gestion-notes --url

echo ""
echo "Pour ouvrir dans le navigateur:"
echo "minikube service frontend-service -n gestion-notes"

echo ""
echo "IDENTIFIANTS:"
echo "- Admin: admin@gestion-notes.com / password"
echo "- Professeur: prof@test.com / password"
echo "- Etudiant: etudiant@test.com / password"