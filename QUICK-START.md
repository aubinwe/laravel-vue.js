# 🚀 Guide de Démarrage DevOps - Gestion de Notes

## Démarrage Rapide (5 minutes)

### 1. Prérequis
```bash
# Vérifier les outils
docker --version
kubectl version --client
git --version
```

### 2. Configuration initiale
```bash
# Cloner et configurer
git clone <votre-repo>
cd gestionNote

# Configurer les secrets GitHub
# Dans GitHub > Settings > Secrets:
DOCKER_USERNAME=votre-username
DOCKER_PASSWORD=votre-token
KUBE_CONFIG=base64-encoded-kubeconfig
```

### 3. Déploiement local (développement)
```bash
# Démarrage rapide avec Docker Compose
docker-compose up -d

# Vérifier le statut
docker-compose ps
```

### 4. Déploiement Kubernetes (production)
```bash
# Déploiement complet
chmod +x deploy-devops.sh
./deploy-devops.sh deploy

# Accès aux services
kubectl port-forward svc/frontend-service 8080:80 -n gestion-notes
```

## URLs d'accès

- **Application**: http://localhost:8080
- **API**: http://localhost:8000/api
- **Grafana**: http://grafana.local
- **Prometheus**: http://prometheus.local

## Comptes de test

- **Admin**: admin@gestion-notes.com / password
- **Professeur**: prof@test.com / password
- **Étudiant**: etudiant@test.com / password

## Commandes utiles

```bash
# Logs en temps réel
kubectl logs -f deployment/backend-deployment -n gestion-notes

# Scaling
kubectl scale deployment backend-deployment --replicas=3 -n gestion-notes

# Debug
kubectl exec -it deployment/backend-deployment -n gestion-notes -- bash

# Monitoring
kubectl port-forward svc/grafana 3000:3000 -n monitoring
```

## Résolution de problèmes

### Erreur de connexion base de données
```bash
kubectl get pods -n gestion-notes
kubectl logs mysql-deployment-xxx -n gestion-notes
```

### Pipeline CI/CD en échec
1. Vérifier les secrets GitHub
2. Contrôler les logs d'actions
3. Valider la syntaxe YAML

### Monitoring non accessible
```bash
kubectl get pods -n monitoring
kubectl port-forward svc/prometheus 9090:9090 -n monitoring
```

## Support

- 📧 Email: devops@gestion-notes.com
- 💬 Slack: #devops-support
- 📖 Wiki: [Documentation complète](./DEVOPS-ARCHITECTURE.md)