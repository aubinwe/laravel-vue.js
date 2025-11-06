# Déploiement WSL avec Monitoring

## Commandes WSL

```bash
# 1. Aller dans le projet
cd /mnt/c/xampp/htdocs/gestionNote

# 2. Rendre le script exécutable
chmod +x deploy-wsl.sh

# 3. Démarrer avec monitoring
./deploy-wsl.sh
```

## Accès depuis WSL

- **Application**: http://localhost
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin)
- **API**: http://localhost:8000

## Vérification

```bash
# Voir les conteneurs
docker-compose ps

# Voir les logs
docker-compose logs grafana
docker-compose logs prometheus
```