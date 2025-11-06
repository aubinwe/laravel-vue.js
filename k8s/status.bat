@echo off
echo ========================================
echo   STATUT KUBERNETES
echo ========================================

echo.
echo Pods:
kubectl get pods -n gestion-notes -o wide

echo.
echo Services:
kubectl get services -n gestion-notes

echo.
echo Ingress:
kubectl get ingress -n gestion-notes

echo.
echo Logs Backend (derniers):
kubectl logs -l app=backend -n gestion-notes --tail=10

echo.
echo Logs Frontend (derniers):
kubectl logs -l app=frontend -n gestion-notes --tail=10

pause