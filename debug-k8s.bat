@echo off
echo ========================================
echo       DIAGNOSTIC KUBERNETES
echo ========================================

echo === STATUT GENERAL ===
kubectl get all -n gestion-notes

echo.
echo === PODS DETAILS ===
kubectl describe pods -n gestion-notes

echo.
echo === SERVICES DETAILS ===
kubectl describe services -n gestion-notes

echo.
echo === LOGS BACKEND ===
echo --- Derniers logs backend ---
kubectl logs --tail=20 -l app=backend -n gestion-notes

echo.
echo === LOGS FRONTEND ===
echo --- Derniers logs frontend ---
kubectl logs --tail=20 -l app=frontend -n gestion-notes

echo.
echo === LOGS MYSQL ===
echo --- Derniers logs MySQL ---
kubectl logs --tail=20 -l app=mysql -n gestion-notes

echo.
echo === TESTS DE CONNECTIVITE ===
echo Test de resolution DNS...
kubectl run test-dns --image=busybox --rm -it --restart=Never -n gestion-notes -- nslookup mysql-service

echo Test de connectivite MySQL...
kubectl run test-mysql --image=mysql:8.0 --rm -it --restart=Never -n gestion-notes -- mysql -h mysql-service -u root -prootpassword -e "SELECT 'MySQL OK' as status;"

echo Test de connectivite Backend...
kubectl run test-backend --image=curlimages/curl --rm -it --restart=Never -n gestion-notes -- curl -s http://backend-service:8000/api/health

echo Test de connectivite Frontend...
kubectl run test-frontend --image=curlimages/curl --rm -it --restart=Never -n gestion-notes -- curl -s http://frontend-service/health

echo.
echo === ACCES EXTERNE ===
echo Port-forward pour test local:
echo kubectl port-forward service/frontend-service 8080:80 -n gestion-notes
echo Puis ouvrir: http://localhost:8080

pause