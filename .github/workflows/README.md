# Pipeline CI/CD - Gestion de Notes

## Vue d'ensemble

Ce pipeline automatise le processus de développement, test et déploiement de l'application Gestion de Notes.

## Workflows

### 1. CI/CD Principal (`ci-cd.yml`)

**Déclencheurs :**
- Push sur `main` ou `develop`
- Pull Request vers `main`

**Étapes :**
1. **Tests Backend** : Tests PHP avec base de données MySQL
2. **Tests Frontend** : Linting et build Vue.js
3. **Build & Push** : Construction et publication des images Docker
4. **Deploy** : Déploiement automatique sur Kubernetes

### 2. Sécurité (`security.yml`)

**Déclencheurs :**
- Push sur `main` ou `develop`
- Pull Request vers `main`
- Planifié : tous les lundis à 2h

**Scans :**
- Code source (Trivy)
- Dépendances PHP et Node.js
- Images Docker

## Configuration requise

### Secrets GitHub

```
GITHUB_TOKEN : Token automatique pour GitHub Container Registry
KUBE_CONFIG : Configuration kubectl encodée en base64
```

### Variables d'environnement

```
REGISTRY=ghcr.io
IMAGE_NAME_BACKEND=${{ github.repository }}/backend
IMAGE_NAME_FRONTEND=${{ github.repository }}/frontend
```

## Utilisation

1. **Développement** : Créez une branche feature
2. **Tests** : Push déclenche les tests automatiques
3. **Review** : Créez une Pull Request vers `main`
4. **Déploiement** : Merge sur `main` déclenche le déploiement

## Monitoring

- Logs disponibles dans l'onglet Actions
- Status des déploiements dans Kubernetes
- Rapports de sécurité dans Security tab