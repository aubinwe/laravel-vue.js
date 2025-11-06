#!/bin/bash

echo "========================================"
echo "      DIAGNOSTIC KUBERNETES"
echo "========================================"

echo "=== STATUT GENERAL ==="
kubectl get all -n gestion-notes

echo ""
echo "=== LOGS BACKEND ==="
kubectl logs --tail=20 -l app=backend -n gestion-notes

echo ""
echo "=== LOGS FRONTEND ==="
kubectl logs --tail=20 -l app=frontend -n gestion-notes

echo ""
echo "=== LOGS MYSQL ==="
kubectl logs --tail=20 -l app=mysql -n gestion-notes

echo ""
echo "=== TESTS DE CONNECTIVITE ==="
echo "Test MySQL..."
kubectl run test-mysql --image=mysql:8.0 --rm -i --restart=Never -n gestion-notes -- mysql -h mysql-service -u root -prootpassword -e "SELECT 'MySQL OK' as status;" 2>/dev/null || echo "MySQL: KO"

echo "Test Backend..."
kubectl run test-backend --image=curlimages/curl --rm -i --restart=Never -n gestion-notes -- curl -s http://backend-service:8000/api/health 2>/dev/null || echo "Backend: KO"

echo ""
echo "=== ACCES EXTERNE ==="
echo "Pour tester localement:"
echo "kubectl port-forward service/frontend-service 8080:80 -n gestion-notes"
echo "Puis ouvrir: http://localhost:8080"