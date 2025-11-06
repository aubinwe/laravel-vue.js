# 🎓 Gestion de Notes - Application Web

Application complète de gestion de notes universitaires avec architecture 3-tiers et pipeline CI/CD.

## 🏗️ Architecture

### Vue d'ensemble
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │    Backend      │    │   Base de       │
│   Vue.js 3      │◄──►│   Laravel 11    │◄──►│   Données       │
│   Port 80       │    │   Port 8000     │    │   MySQL 8.0     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Composants
- **Frontend**: Vue.js 3 + Pinia + Tailwind CSS (SPA)
- **Backend**: Laravel 11 + Sanctum (API REST)
- **Base de données**: MySQL 8.0 (Relationnelle)
- **Reverse Proxy**: Nginx (Routage des requêtes)
- **Monitoring**: Prometheus + Grafana
- **Conteneurisation**: Docker + Docker Compose

## 🚀 Déploiement

### Prérequis
- Docker Desktop installé et démarré
- Git

### Commandes de déploiement
```bash
# 1. Cloner le projet
git clone <votre-repo>
cd gestionNote

# 2. Démarrer l'application complète
docker-compose up -d

# 3. Vérifier l'état des services
docker-compose ps

# 4. Voir les logs
docker-compose logs -f
```

### Alternative XAMPP
```bash
# Si Docker ne fonctionne pas
SOLUTION-FINALE.bat
```

## 🔐 Comptes de Test

- **Admin**: `admin@gestion-notes.com` / `password`
- **Professeur**: `prof@test.com` / `password`
- **Étudiant**: `etudiant@test.com` / `password`

## 🌐 URLs d'Accès

### Avec Docker (Production)
- **Application**: http://localhost
- **API Backend**: http://localhost:8000
- **Base de données**: Port 3307
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin)

### Avec XAMPP (Développement)
- **Application**: http://localhost:5173
- **API Backend**: http://localhost:8000
- **Base de données**: http://localhost/phpmyadmin

## 🔄 Pipeline CI/CD

### Architecture du Pipeline
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Source    │    │    Build    │    │    Test     │    │   Deploy    │
│   GitHub    │───►│   Docker    │───►│   PHPUnit   │───►│   Registry  │
│   Push      │    │   Images    │    │   Jest      │    │   Production│
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

### Étapes du Pipeline (.github/workflows/ci-cd.yml)

#### 1. **Test Stage**
```yaml
- name: Test Backend
  run: |
    composer install
    php artisan test
    
- name: Test Frontend  
  run: |
    npm ci
    npm run test
```

#### 2. **Build Stage**
```yaml
- name: Build Docker Images
  run: |
    docker build -t backend ./appNotes
    docker build -t frontend ./frontend
```

#### 3. **Security Scan**
```yaml
- name: Security Scan
  run: |
    docker run --rm -v $(pwd):/app securecodewarrior/docker-security-scan
```

#### 4. **Deploy Stage**
```yaml
- name: Deploy to Production
  run: |
    docker-compose -f docker-compose.prod.yml up -d
```

### Déclencheurs du Pipeline
- **Push** sur `main` → Déploiement automatique
- **Pull Request** → Tests uniquement
- **Tag** → Release avec versioning

### Commandes de gestion
```bash
# Déclencher manuellement le pipeline
git tag v1.0.0
git push origin v1.0.0

# Rollback en cas de problème
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.v1.0.0.yml up -d

# Monitoring du déploiement
kubectl get pods -n production
docker-compose logs -f
```

## 📊 Monitoring et Observabilité

### Métriques Prometheus
```promql
# Nombre d'utilisateurs
app_users_total

# Requêtes par seconde
rate(http_requests_total[5m])

# Temps de réponse
histogram_quantile(0.95, http_request_duration_seconds_bucket)

# Erreurs 5xx
rate(http_requests_total{status=~"5.."}[5m])
```

### Dashboards Grafana
- **Application Metrics**: Utilisateurs, notes, réclamations
- **Infrastructure**: CPU, RAM, disque, réseau
- **Performance**: Latence, throughput, erreurs
- **Business**: Connexions, actions utilisateurs

## 🛠️ Technologies

### Stack Technique
- **Frontend**: Vue.js 3, Pinia, Vue Router, Tailwind CSS
- **Backend**: Laravel 11, Sanctum, Eloquent ORM
- **Base de données**: MySQL 8.0
- **Conteneurisation**: Docker, Docker Compose
- **CI/CD**: GitHub Actions
- **Monitoring**: Prometheus, Grafana, Node Exporter
- **Sécurité**: Laravel Sanctum, CORS, Rate Limiting

### Patterns Architecturaux
- **MVC** (Model-View-Controller)
- **Repository Pattern** (Accès aux données)
- **Service Layer** (Logique métier)
- **API REST** (Communication frontend/backend)
- **JWT Authentication** (Sécurité)

## 📁 Structure du Projet

```
gestionNote/
├── .github/workflows/     # Pipeline CI/CD
│   └── ci-cd.yml
├── appNotes/             # Backend Laravel
│   ├── app/
│   ├── database/
│   ├── routes/
│   └── Dockerfile
├── frontend/             # Frontend Vue.js
│   ├── src/
│   ├── public/
│   └── Dockerfile
├── monitoring/           # Configuration monitoring
│   ├── prometheus.yml
│   └── grafana/
├── docker-compose.yml    # Orchestration services
├── deploy-wsl.sh        # Script déploiement WSL
└── README.md            # Documentation
```

## 🔧 Configuration

### Variables d'environnement

#### Production (Docker)
```env
# Backend
DB_HOST=mysql
DB_DATABASE=gestion_notes
DB_USERNAME=root
DB_PASSWORD=root

# Frontend
VITE_API_URL=http://localhost:8000/api
```

#### Développement (XAMPP)
```env
# Backend
DB_HOST=127.0.0.1
DB_DATABASE=gestion_notes
DB_USERNAME=root
DB_PASSWORD=

# Frontend
VITE_API_URL=http://localhost:8000/api
```

## 🐛 Résolution de Problèmes

### Docker
```bash
# Vérifier Docker Desktop
docker --version

# Redémarrer les conteneurs
docker-compose down
docker-compose up -d

# Nettoyer les images
docker system prune -f
```

### Pipeline CI/CD
```bash
# Vérifier les logs GitHub Actions
gh run list
gh run view <run-id>

# Tests locaux avant push
composer test
npm run test
```

### Monitoring
```bash
# Vérifier Prometheus targets
curl http://localhost:9090/api/v1/targets

# Redémarrer Grafana
docker-compose restart grafana
```

## 📞 Support

Pour toute question technique :
1. Vérifier les logs : `docker-compose logs`
2. Consulter la documentation API : http://localhost:8000/api/documentation
3. Créer une issue sur GitHub

## 📄 Licence

MIT License