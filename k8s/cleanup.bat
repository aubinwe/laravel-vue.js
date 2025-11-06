@echo off
echo ========================================
echo   NETTOYAGE KUBERNETES
echo ========================================

echo.
echo Suppression des ressources...
kubectl delete namespace gestion-notes

echo.
echo Suppression des images Docker...
docker rmi gestion-notes/backend:latest
docker rmi gestion-notes/frontend:latest

echo.
echo Nettoyage termine !
pause