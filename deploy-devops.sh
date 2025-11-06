#!/bin/bash

# 🚀 Script de déploiement DevOps complet
# Gestion de Notes - Architecture DevOps

set -e

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
NAMESPACE="gestion-notes"
MONITORING_NAMESPACE="monitoring"
DOCKER_REGISTRY="docker.io"
IMAGE_PREFIX="votre-username/gestion-notes"

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

# Vérification des prérequis
check_prerequisites() {
    log "🔍 Vérification des prérequis..."
    
    command -v docker >/dev/null 2>&1 || error "Docker n'est pas installé"
    command -v kubectl >/dev/null 2>&1 || error "kubectl n'est pas installé"
    command -v helm >/dev/null 2>&1 || warn "Helm n'est pas installé (optionnel)"
    
    # Vérifier la connexion au cluster
    kubectl cluster-info >/dev/null 2>&1 || error "Impossible de se connecter au cluster Kubernetes"
    
    log "✅ Prérequis validés"
}

# Construction des images Docker
build_images() {
    log "🏗️ Construction des images Docker..."
    
    # Backend
    log "📦 Construction de l'image backend..."
    docker build -t ${IMAGE_PREFIX}-backend:latest ./appNotes
    docker tag ${IMAGE_PREFIX}-backend:latest ${IMAGE_PREFIX}-backend:$(git rev-parse --short HEAD)
    
    # Frontend
    log "🎨 Construction de l'image frontend..."
    docker build -t ${IMAGE_PREFIX}-frontend:latest ./frontend
    docker tag ${IMAGE_PREFIX}-frontend:latest ${IMAGE_PREFIX}-frontend:$(git rev-parse --short HEAD)
    
    # Database
    log "🗄️ Construction de l'image database..."
    docker build -t ${IMAGE_PREFIX}-database:latest ./database
    docker tag ${IMAGE_PREFIX}-database:latest ${IMAGE_PREFIX}-database:$(git rev-parse --short HEAD)
    
    log "✅ Images construites avec succès"
}

# Push des images vers le registry
push_images() {
    log "📤 Push des images vers le registry..."
    
    docker push ${IMAGE_PREFIX}-backend:latest
    docker push ${IMAGE_PREFIX}-backend:$(git rev-parse --short HEAD)
    
    docker push ${IMAGE_PREFIX}-frontend:latest
    docker push ${IMAGE_PREFIX}-frontend:$(git rev-parse --short HEAD)
    
    docker push ${IMAGE_PREFIX}-database:latest
    docker push ${IMAGE_PREFIX}-database:$(git rev-parse --short HEAD)
    
    log "✅ Images pushées avec succès"
}

# Déploiement de l'application
deploy_application() {
    log "🚀 Déploiement de l'application..."
    
    # Création du namespace
    kubectl apply -f k8s/01-namespace.yaml
    
    # Configuration et secrets
    kubectl apply -f k8s/02-configmap.yaml
    kubectl apply -f k8s/03-secrets.yaml
    
    # Base de données
    log "🗄️ Déploiement de MySQL..."
    kubectl apply -f k8s/04-mysql.yaml
    kubectl rollout status deployment/mysql-deployment -n ${NAMESPACE} --timeout=300s
    
    # Backend
    log "⚙️ Déploiement du backend..."
    kubectl apply -f k8s/05-backend.yaml
    kubectl rollout status deployment/backend-deployment -n ${NAMESPACE} --timeout=300s
    
    # Frontend
    log "🎨 Déploiement du frontend..."
    kubectl apply -f k8s/06-frontend.yaml
    kubectl rollout status deployment/frontend-deployment -n ${NAMESPACE} --timeout=300s
    
    # Ingress
    log "🌐 Configuration de l'ingress..."
    kubectl apply -f k8s/07-ingress.yaml
    
    log "✅ Application déployée avec succès"
}

# Déploiement du monitoring
deploy_monitoring() {
    log "📊 Déploiement du monitoring..."
    
    # Namespace monitoring
    kubectl apply -f k8s/monitoring/01-monitoring-namespace.yaml
    
    # Prometheus
    log "📈 Déploiement de Prometheus..."
    kubectl apply -f k8s/monitoring/02-prometheus-config.yaml
    kubectl apply -f k8s/monitoring/03-prometheus.yaml
    
    # Grafana
    log "📊 Déploiement de Grafana..."
    kubectl apply -f k8s/monitoring/04-grafana.yaml
    kubectl apply -f k8s/monitoring/05-grafana-dashboards.yaml
    
    # Ingress monitoring
    kubectl apply -f k8s/monitoring/06-monitoring-ingress.yaml
    
    log "✅ Monitoring déployé avec succès"
}

# Tests post-déploiement
run_tests() {
    log "🧪 Exécution des tests post-déploiement..."
    
    # Attendre que les pods soient prêts
    kubectl wait --for=condition=ready pod -l app=backend -n ${NAMESPACE} --timeout=300s
    kubectl wait --for=condition=ready pod -l app=frontend -n ${NAMESPACE} --timeout=300s
    
    # Test de santé de l'API
    BACKEND_POD=$(kubectl get pods -n ${NAMESPACE} -l app=backend -o jsonpath='{.items[0].metadata.name}')
    kubectl exec -n ${NAMESPACE} ${BACKEND_POD} -- curl -f http://localhost/api/health || error "Health check failed"
    
    log "✅ Tests post-déploiement réussis"
}

# Affichage du statut
show_status() {
    log "📋 Statut du déploiement:"
    
    echo -e "\n${BLUE}=== PODS ===${NC}"
    kubectl get pods -n ${NAMESPACE}
    
    echo -e "\n${BLUE}=== SERVICES ===${NC}"
    kubectl get services -n ${NAMESPACE}
    
    echo -e "\n${BLUE}=== INGRESS ===${NC}"
    kubectl get ingress -n ${NAMESPACE}
    
    echo -e "\n${BLUE}=== MONITORING ===${NC}"
    kubectl get pods -n ${MONITORING_NAMESPACE}
    
    # URLs d'accès
    echo -e "\n${GREEN}🌐 URLs d'accès:${NC}"
    echo "Application: http://gestion-notes.local"
    echo "Grafana: http://grafana.local"
    echo "Prometheus: http://prometheus.local"
}

# Nettoyage
cleanup() {
    log "🧹 Nettoyage..."
    kubectl delete namespace ${NAMESPACE} --ignore-not-found=true
    kubectl delete namespace ${MONITORING_NAMESPACE} --ignore-not-found=true
    log "✅ Nettoyage terminé"
}

# Menu principal
main() {
    case "${1:-deploy}" in
        "build")
            check_prerequisites
            build_images
            ;;
        "push")
            check_prerequisites
            push_images
            ;;
        "deploy")
            check_prerequisites
            build_images
            push_images
            deploy_application
            deploy_monitoring
            run_tests
            show_status
            ;;
        "monitoring")
            check_prerequisites
            deploy_monitoring
            ;;
        "test")
            run_tests
            ;;
        "status")
            show_status
            ;;
        "cleanup")
            cleanup
            ;;
        *)
            echo "Usage: $0 {build|push|deploy|monitoring|test|status|cleanup}"
            echo ""
            echo "Commands:"
            echo "  build      - Construire les images Docker"
            echo "  push       - Pousser les images vers le registry"
            echo "  deploy     - Déploiement complet (build + push + deploy + monitoring)"
            echo "  monitoring - Déployer uniquement le monitoring"
            echo "  test       - Exécuter les tests post-déploiement"
            echo "  status     - Afficher le statut du déploiement"
            echo "  cleanup    - Nettoyer les ressources"
            exit 1
            ;;
    esac
}

main "$@"