# 🚀 Commandes DevOps - Gestion de Notes

## 🐳 Phase 1: Docker

### Construction et test
```bash
# Déploiement automatique
chmod +x quick-deploy.sh
./quick-deploy.sh

# Ou manuel:
docker-compose -f docker-compose.prod.yml up --build -d
docker-compose -f docker-compose.prod.yml ps
docker-compose -f docker-compose.prod.yml logs backend
```

### Vérification Docker
```bash
# Test API
curl http://localhost:8000/api/health

# Test application
curl http://localhost

# Logs
docker-compose -f docker-compose.prod.yml logs -f backend
```

## ☸️ Phase 2: Kubernetes

### Déploiement
```bash
# Application
kubectl apply -f k8s/01-namespace.yaml
kubectl apply -f k8s/02-configmap.yaml
kubectl apply -f k8s/03-secrets.yaml
kubectl apply -f k8s/04-mysql.yaml
kubectl apply -f k8s/05-backend.yaml
kubectl apply -f k8s/06-frontend.yaml
kubectl apply -f k8s/07-ingress.yaml

# Ou tout en une fois
kubectl apply -f k8s/
```

### Vérification Kubernetes
```bash
# Statut des pods
kubectl get pods -n gestion-notes

# Logs
kubectl logs -l app=backend -n gestion-notes

# Port-forward pour test
kubectl port-forward service/backend-service 8000:8000 -n gestion-notes
```

## 📊 Phase 3: Monitoring

### Déploiement Monitoring
```bash
# Prometheus + Grafana
kubectl apply -f k8s/monitoring/

# Vérification
kubectl get pods -n monitoring
```

### Accès Monitoring
```bash
# Port-forwards
kubectl port-forward service/grafana-service 3000:3000 -n monitoring
kubectl port-forward service/prometheus-service 9090:9090 -n monitoring

# URLs
# Grafana: http://localhost:3000 (admin/admin123)
# Prometheus: http://localhost:9090
```

## 🔧 Commandes de Debug

### Docker
```bash
# Entrer dans le conteneur
docker exec -it gestion-notes-backend bash

# Voir les logs
docker-compose -f docker-compose.prod.yml logs backend

# Redémarrer un service
docker-compose -f docker-compose.prod.yml restart backend
```

### Kubernetes
```bash
# Debug pod
kubectl describe pod <pod-name> -n gestion-notes
kubectl logs <pod-name> -n gestion-notes

# Entrer dans un pod
kubectl exec -it <pod-name> -n gestion-notes -- bash

# Redémarrer un déploiement
kubectl rollout restart deployment/backend -n gestion-notes
```

## 🧹 Nettoyage

### Docker
```bash
docker-compose -f docker-compose.prod.yml down -v
docker system prune -a
```

### Kubernetes
```bash
kubectl delete namespace gestion-notes
kubectl delete namespace monitoring
```

## 📋 Checklist de Vérification

### ✅ Docker
- [ ] Images construites sans erreur
- [ ] Conteneurs en cours d'exécution
- [ ] API répond sur http://localhost:8000/api/health
- [ ] Application accessible sur http://localhost

### ✅ Kubernetes
- [ ] Tous les pods en état "Running"
- [ ] Services créés
- [ ] Ingress configuré
- [ ] Application accessible via port-forward

### ✅ Monitoring
- [ ] Prometheus collecte les métriques
- [ ] Grafana accessible avec dashboards
- [ ] Alertes configurées

## 🎯 URLs Finales

- **Application**: http://localhost (Docker) ou port-forward K8s
- **API**: http://localhost:8000/api
- **Grafana**: http://localhost:3000 (admin/admin123)
- **Prometheus**: http://localhost:9090

## 👤 Comptes de Test

- **Admin**: admin@gestion-notes.com / password
- **Professeur**: prof@test.com / password
- **Étudiant**: etudiant@test.com / password