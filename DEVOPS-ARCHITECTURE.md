# 🚀 Architecture DevOps - Gestion de Notes

## Vue d'ensemble

Cette documentation présente l'architecture DevOps complète mise en place pour l'application de gestion de notes universitaires, incluant la conteneurisation, l'orchestration Kubernetes, le pipeline CI/CD et le monitoring.

## 🏗️ Architecture

### Composants principaux

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │    Backend      │    │   Database      │
│   (Vue.js)      │◄──►│   (Laravel)     │◄──►│    (MySQL)      │
│   Port: 80      │    │   Port: 8000    │    │   Port: 3306    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Monitoring    │
                    │ Prometheus +    │
                    │   Grafana       │
                    └─────────────────┘
```

### Technologies utilisées

- **Frontend**: Vue.js 3, Pinia, Tailwind CSS
- **Backend**: Laravel 11, PHP 8.2, Sanctum
- **Database**: MySQL 8.0
- **Conteneurisation**: Docker, Docker Compose
- **Orchestration**: Kubernetes
- **CI/CD**: GitHub Actions
- **Monitoring**: Prometheus, Grafana
- **Reverse Proxy**: Nginx

## 🐳 Conteneurisation

### Structure des Dockerfiles

#### Frontend (Multi-stage)
```dockerfile
# Build stage
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
```

#### Backend (Optimisé)
```dockerfile
# Build stage
FROM composer:2.6 AS composer
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts

# Production stage
FROM php:8.2-apache
RUN apt-get update && apt-get install -y libpng-dev libxml2-dev
RUN docker-php-ext-install pdo_mysql gd
COPY --from=composer /app/vendor ./vendor
COPY . .
```

### Optimisations appliquées

1. **Multi-stage builds** pour réduire la taille des images
2. **Layer caching** pour accélérer les builds
3. **Security scanning** intégré
4. **Health checks** pour la surveillance

## ☸️ Déploiement Kubernetes

### Namespace et organisation

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: gestion-notes
  labels:
    name: gestion-notes
    environment: production
```

### Stratégie de déploiement

- **Rolling Updates** avec zéro downtime
- **Health checks** (liveness, readiness, startup)
- **Resource limits** et requests
- **Security contexts** appliqués

### Services et exposition

```yaml
# Service Backend
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  selector:
    app: backend
  ports:
  - port: 8000
    targetPort: 80
```

## 🔄 Pipeline CI/CD

### Workflow GitHub Actions

Le pipeline est divisé en 3 étapes principales :

#### 1. Tests et Qualité
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mysql:8.0
    steps:
    - name: Backend Tests
      run: php artisan test --coverage
    - name: Frontend Tests
      run: npm run lint && npm run build
    - name: Security Scan
      run: composer audit
```

#### 2. Build et Push
```yaml
  build:
    strategy:
      matrix:
        service: [backend, frontend, database]
    steps:
    - name: Build and push
      uses: docker/build-push-action@v5
      with:
        context: ${{ matrix.service }}
        push: true
        tags: ${{ env.IMAGE_PREFIX }}-${{ matrix.service }}:latest
```

#### 3. Déploiement
```yaml
  deploy:
    steps:
    - name: Deploy to Kubernetes
      run: |
        kubectl apply -f k8s/
        kubectl rollout status deployment/backend-deployment
```

### Déclencheurs

- **Push** sur `main` et `develop`
- **Pull Requests** vers `main`
- **Tags** pour les releases

## 📊 Monitoring et Observabilité

### Prometheus Configuration

```yaml
scrape_configs:
  - job_name: 'gestion-notes-backend'
    kubernetes_sd_configs:
      - role: endpoints
        namespaces:
          names: [gestion-notes]
```

### Métriques collectées

1. **Application**
   - Taux de requêtes HTTP
   - Temps de réponse
   - Taux d'erreur
   - Connexions base de données

2. **Infrastructure**
   - Utilisation CPU/Mémoire
   - Statut des pods
   - Latence réseau

### Dashboard Grafana

Le dashboard inclut :
- **Application Health** : Statut des services
- **Performance** : Temps de réponse, throughput
- **Resources** : CPU, mémoire, stockage
- **Alertes** : Seuils critiques configurés

### Alertes configurées

```yaml
- alert: HighErrorRate
  expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
  for: 5m
  labels:
    severity: critical

- alert: HighMemoryUsage
  expr: container_memory_usage_bytes / container_spec_memory_limit_bytes > 0.8
  for: 5m
  labels:
    severity: warning
```

## 🔒 Sécurité

### Mesures implémentées

1. **Images Docker**
   - Scan de vulnérabilités
   - Images minimales (Alpine)
   - Utilisateurs non-root

2. **Kubernetes**
   - Security contexts
   - Network policies
   - RBAC configuré
   - Secrets management

3. **Application**
   - HTTPS forcé
   - Headers de sécurité
   - Validation des entrées
   - Authentification JWT

## 🚀 Déploiement

### Prérequis

```bash
# Outils requis
- Docker 20.10+
- kubectl 1.28+
- Helm 3.0+ (optionnel)
- Accès cluster Kubernetes
```

### Déploiement rapide

```bash
# Cloner le projet
git clone <votre-repo>
cd gestionNote

# Déploiement complet
chmod +x deploy-devops.sh
./deploy-devops.sh deploy
```

### Commandes utiles

```bash
# Build uniquement
./deploy-devops.sh build

# Monitoring uniquement
./deploy-devops.sh monitoring

# Statut du déploiement
./deploy-devops.sh status

# Nettoyage
./deploy-devops.sh cleanup
```

## 📈 Métriques et KPIs

### Métriques techniques

- **Availability**: > 99.9%
- **Response Time**: < 200ms (P95)
- **Error Rate**: < 0.1%
- **Build Time**: < 5 minutes

### Métriques business

- **Deployment Frequency**: Multiple par jour
- **Lead Time**: < 1 heure
- **MTTR**: < 15 minutes
- **Change Failure Rate**: < 5%

## 🔧 Maintenance

### Tâches régulières

1. **Mise à jour des dépendances**
2. **Rotation des secrets**
3. **Nettoyage des images**
4. **Backup des données**

### Procédures d'urgence

1. **Rollback automatique** en cas d'échec
2. **Scaling horizontal** en cas de charge
3. **Alertes temps réel** via Slack/Email

## 📚 Ressources

- [Documentation Kubernetes](https://kubernetes.io/docs/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Prometheus Monitoring](https://prometheus.io/docs/)
- [Laravel Deployment](https://laravel.com/docs/deployment)

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature
3. Commit les changements
4. Push vers la branche
5. Créer une Pull Request

---

**Auteur**: Équipe DevOps  
**Version**: 1.0.0  
**Dernière mise à jour**: $(date)