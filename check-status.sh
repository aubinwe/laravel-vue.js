#!/bin/bash

echo "=== VERIFICATION KUBERNETES ==="

echo "1. Cluster info:"
kubectl cluster-info

echo ""
echo "2. Namespaces:"
kubectl get namespaces

echo ""
echo "3. Services dans gestion-notes:"
kubectl get services -n gestion-notes 2>/dev/null || echo "Namespace gestion-notes n'existe pas"

echo ""
echo "4. Pods dans gestion-notes:"
kubectl get pods -n gestion-notes 2>/dev/null || echo "Aucun pod dans gestion-notes"

echo ""
echo "5. Tous les services:"
kubectl get services --all-namespaces

echo ""
echo "=== DIAGNOSTIC ==="
if kubectl get namespace gestion-notes >/dev/null 2>&1; then
    echo "✓ Namespace gestion-notes existe"
else
    echo "✗ Namespace gestion-notes n'existe pas - Déploiement nécessaire"
fi