# 🚀 Architecture DevOps - Gestion de Notes

## 📋 Vue d'ensemble

Application de gestion de notes universitaires avec architecture DevOps complète :
- **Frontend**: Vue.js 3 + Tailwind CSS
- **Backend**: Laravel 11 + Sanctum
- **Base de données**: MySQL 8.0
- **Conteneurisation**: Docker + Docker Compose
- **Orchestration**: Kubernetes
- **CI/CD**: GitHub Actions
- **Monitoring**: Prometheus + Grafana

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │    Backend      │    │    Database     │
│   (Vue.js)      │◄──►│   (Laravel)     │◄──►│    (MySQL)      │
│   Port: 80      │    │   Port: 8000    │    │   Port: 3306    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Kubernetes    │
                    │   Cluster       │
                    └─────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Monitoring    │
                    │ Prometheus +    │
                    │   Grafana       │
                    └─────────────────┘
```

## 🚀 Démarrage Rapide

### Prérequis
- Docker Desktop
- Kubernetes (minikube recommandé)
- kubectl
- Git

### Test Complet
```cmd
# Cloner le projet
git clone <votre-repo>
cd gestionNote

# Lancer le test complet
test-devops-complet.bat

# Déployer le monitoring
deploy-monitoring.bat
```

## 🐳 Conteneurisation

### Images Docker
- **Frontend**: `nginx:alpine` + Vue.js build
- **Backend**: `php:8.2-fpm` + nginx + supervisor
- **Database**: `mysql:8.0`

### Construction locale
```cmd
docker-compose build
docker-compose up -d
```

## ☸️ Kubernetes

### Namespaces
- `gestion-notes`: Application principale
- `monitoring`: Prometheus + Grafana

### Déploiement
```cmd
kubectl apply -f k8s/
kubectl get pods -n gestion-notes
```

### Accès aux services
```cmd
# Frontend
kubectl port-forward -n gestion-notes service/frontend-service 8080:80

# Backend API
kubectl port-forward -n gestion-notes service/backend-service 8000:8000

# Grafana
kubectl port-forward -n monitoring service/grafana-service 3000:3000
```

## 🔄 Pipeline CI/CD

### GitHub Actions
- **Tests**: Backend (PHPUnit) + Frontend (ESLint)
- **Build**: Images Docker automatiques
- **Deploy**: Déploiement Kubernetes automatique

### Déclencheurs
- Push sur `main`: Déploiement complet
- Pull Request: Tests uniquement

## 📊 Monitoring

### Prometheus
- Métriques Kubernetes
- Métriques applicatives
- Alerting configuré

### Grafana
- Dashboards Kubernetes
- Métriques applicatives
- Login: `admin` / `admin123`

## 🔧 Configuration

### Variables d'environnement

#### Backend (.env)
```env
DB_HOST=mysql-service
DB_PORT=3306
DB_DATABASE=gestion_notes
DB_USERNAME=root
DB_PASSWORD=rootpassword
```

#### Frontend (.env)
```env
VITE_API_URL=http://backend-service:8000/api
```

## 🧪 Tests

### Tests automatisés
```cmd
# Backend
cd appNotes
php artisan test

# Frontend
cd frontend
npm run test
npm run lint
```

### Tests manuels
```cmd
# Test API
curl http://localhost:8000/api/health

# Test Frontend
curl http://localhost:8080
```

## 📁 Structure du projet

```
gestionNote/
├── appNotes/              # Backend Laravel
│   ├── docker/           # Configuration Docker
│   └── Dockerfile        # Image backend
├── frontend/             # Frontend Vue.js
│   ├── nginx.conf       # Configuration nginx
│   └── Dockerfile       # Image frontend
├── k8s/                 # Manifests Kubernetes
│   ├── monitoring/      # Prometheus + Grafana
│   ├── 01-namespace.yaml
│   ├── 04-mysql.yaml
│   ├── 05-backend.yaml
│   └── 06-frontend.yaml
├── .github/workflows/   # Pipeline CI/CD
└── docker-compose.yml   # Développement local
```

## 🐛 Dépannage

### Problèmes courants

#### Pods en erreur
```cmd
kubectl describe pod <pod-name> -n gestion-notes
kubectl logs <pod-name> -n gestion-notes
```

#### Base de données
```cmd
kubectl exec -it <mysql-pod> -n gestion-notes -- mysql -u root -p
```

#### Images Docker
```cmd
docker-compose logs backend
docker-compose logs frontend
```

## 📈 Métriques

### Indicateurs surveillés
- CPU/Mémoire des pods
- Latence des requêtes HTTP
- Erreurs applicatives
- Disponibilité des services

### Alertes configurées
- Pod down > 5min
- CPU > 80% pendant 10min
- Mémoire > 90% pendant 5min

## 🔒 Sécurité

### Bonnes pratiques implémentées
- Images non-root
- Secrets Kubernetes
- Network policies
- Resource limits
- Health checks

## 📞 Support

### Commandes utiles
```cmd
# Statut général
kubectl get all -n gestion-notes

# Logs en temps réel
kubectl logs -f deployment/backend -n gestion-notes

# Shell dans un pod
kubectl exec -it <pod-name> -n gestion-notes -- /bin/bash

# Port forwarding
kubectl port-forward service/frontend-service 8080:80 -n gestion-notes
```

### Contacts
- DevOps Team: devops@gestion-notes.com
- Issues: GitHub Issues

## 📄 Licence
MIT License - Voir LICENSE.md