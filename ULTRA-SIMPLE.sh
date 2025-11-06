#!/bin/bash

echo "=== SOLUTION ULTRA SIMPLE ==="

# 1. NETTOYAGE
kubectl delete namespace gestion-notes --ignore-not-found=true
sleep 10

# 2. NAMESPACE
kubectl create namespace gestion-notes

# 3. MYSQL SIMPLE
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: mysql
  namespace: gestion-notes
  labels:
    app: mysql
spec:
  containers:
  - name: mysql
    image: mysql:8.0
    env:
    - name: MYSQL_ROOT_PASSWORD
      value: "root"
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

echo "Attente MySQL..."
kubectl wait --for=condition=ready pod mysql -n gestion-notes --timeout=120s

# 4. BACKEND SIMPLE
eval $(minikube docker-env)
cd appNotes
docker build -t backend:v1 .
cd ..

kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: backend
  namespace: gestion-notes
  labels:
    app: backend
spec:
  containers:
  - name: backend
    image: backend:v1
    imagePullPolicy: Never
    env:
    - name: DB_HOST
      value: "mysql-service"
    - name: DB_DATABASE
      value: "gestion_notes"
    - name: DB_USERNAME
      value: "root"
    - name: DB_PASSWORD
      value: "root"
    - name: APP_KEY
      value: "base64:c/U/5irtBb+IP8MfGt+eAyRrrIpg/WxiV/gHCByUOGs="
    ports:
    - containerPort: 8000
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

echo "Attente Backend..."
kubectl wait --for=condition=ready pod backend -n gestion-notes --timeout=120s

# 5. INIT BASE
sleep 20
kubectl exec backend -n gestion-notes -- php artisan migrate:fresh --seed --force

# 6. FRONTEND SIMPLE
cd frontend
docker build -t frontend:v1 .
cd ..

kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  namespace: gestion-notes
  labels:
    app: frontend
spec:
  containers:
  - name: frontend
    image: frontend:v1
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
  type: NodePort
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
EOF

echo "Attente Frontend..."
kubectl wait --for=condition=ready pod frontend -n gestion-notes --timeout=120s

# 7. RESULTAT
echo ""
echo "=== TERMINE ==="
kubectl get pods -n gestion-notes
echo ""
echo "ACCES: http://$(minikube ip):30080"
echo "IDENTIFIANTS: admin@gestion-notes.com / password"