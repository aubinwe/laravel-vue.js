# DevOps - CI/CD et Monitoring

## 🚀 Pipeline CI/CD

### GitHub Actions
Le pipeline CI/CD est configuré dans `.github/workflows/ci-cd.yml` :

**Étapes :**
1. **Test** : Tests automatisés backend et frontend
2. **Build** : Construction des images Docker
3. **Push** : Publication sur GitHub Container Registry
4. **Deploy** : Déploiement automatique

**Déclencheurs :**
- Push sur `main` ou `develop`
- Pull requests vers `main`

### Configuration
```bash
# Variables d'environnement requises dans GitHub
GITHUB_TOKEN (automatique)
```

## 📊 Monitoring avec Prometheus & Grafana

### Architecture de Monitoring
- **Prometheus** : Collecte des métriques
- **Grafana** : Visualisation et dashboards
- **Alertmanager** : Gestion des alertes
- **Node Exporter** : Métriques système
- **MySQL Exporter** : Métriques base de données
- **cAdvisor** : Métriques conteneurs

### Déploiement
```bash
# Démarrer avec monitoring
chmod +x deploy-monitoring.sh
./deploy-monitoring.sh
```

### Accès aux Services
- **Application** : http://localhost
- **Prometheus** : http://localhost:9090
- **Grafana** : http://localhost:3000 (admin/admin)
- **Alertmanager** : http://localhost:9093

### Métriques Disponibles
- **Application** : `/api/metrics`
  - Nombre d'utilisateurs
  - Nombre de notes
  - Nombre de réclamations
  - Connexions base de données

- **Système** : Node Exporter
  - CPU, Mémoire, Disque
  - Réseau, Processus

- **Conteneurs** : cAdvisor
  - Utilisation ressources par conteneur
  - Performance conteneurs

### Alertes Configurées
- **Taux d'erreur élevé** : >10% pendant 5min
- **Temps de réponse élevé** : >1s pendant 5min
- **Base de données indisponible** : >1min
- **CPU élevé** : >80% pendant 5min
- **Mémoire élevée** : >85% pendant 5min

### Configuration Grafana
1. Connectez-vous : admin/admin
2. Ajoutez source de données Prometheus : `http://prometheus:9090`
3. Importez le dashboard depuis `monitoring/grafana/dashboards/`

## 🔧 Commandes Utiles

### CI/CD
```bash
# Déclencher le pipeline
git push origin main

# Voir les logs GitHub Actions
gh run list
gh run view <run-id>
```

### Monitoring
```bash
# Voir les métriques
curl http://localhost:8000/api/metrics
curl http://localhost:9100/metrics

# Logs des services
docker-compose -f docker-compose.monitoring.yml logs prometheus
docker-compose -f docker-compose.monitoring.yml logs grafana

# Redémarrer monitoring
docker-compose -f docker-compose.monitoring.yml restart
```

### Kubernetes (optionnel)
```bash
# Déployer monitoring sur K8s
kubectl apply -f k8s/monitoring.yaml

# Accéder aux services
kubectl port-forward -n monitoring service/prometheus 9090:9090
kubectl port-forward -n monitoring service/grafana 3000:3000
```

## 📈 Dashboards Grafana

### Dashboard Principal
- **HTTP Requests Rate** : Taux de requêtes par seconde
- **Response Time** : Temps de réponse 95e percentile
- **Database Connections** : Connexions actives MySQL
- **Memory Usage** : Utilisation mémoire système

### Métriques Personnalisées
- **app_users_total** : Nombre total d'utilisateurs
- **app_grades_total** : Nombre total de notes
- **app_claims_total** : Nombre total de réclamations

## 🚨 Gestion des Alertes

### Configuration Email
Modifiez `monitoring/alertmanager.yml` :
```yaml
global:
  smtp_smarthost: 'your-smtp-server:587'
  smtp_from: 'alerts@your-domain.com'

receivers:
- name: 'web.hook'
  email_configs:
  - to: 'admin@your-domain.com'
```

### Webhook Slack/Teams
```yaml
webhook_configs:
- url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'
```

## 🔒 Sécurité

### Secrets Management
- Utilisez GitHub Secrets pour les tokens
- Variables d'environnement pour les mots de passe
- Rotation régulière des clés

### Monitoring Sécurisé
- Authentification Grafana
- HTTPS en production
- Firewall pour Prometheus

## 📝 Maintenance

### Sauvegarde
```bash
# Sauvegarder les données Grafana
docker-compose -f docker-compose.monitoring.yml exec grafana tar -czf /tmp/grafana-backup.tar.gz /var/lib/grafana

# Sauvegarder config Prometheus
cp -r monitoring/ backup/monitoring-$(date +%Y%m%d)/
```

### Mise à jour
```bash
# Mettre à jour les images
docker-compose -f docker-compose.monitoring.yml pull
docker-compose -f docker-compose.monitoring.yml up -d
```