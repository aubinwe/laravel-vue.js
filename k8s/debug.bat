@echo off
echo === DIAGNOSTIC KUBERNETES ===

echo 1. Statut des pods:
kubectl get pods -o wide

echo.
echo 2. Statut des services:
kubectl get services

echo.
echo 3. Statut de l'ingress:
kubectl get ingress

echo.
echo 4. Logs du frontend:
kubectl logs -l app=frontend --tail=20

echo.
echo 5. Logs du backend:
kubectl logs -l app=backend --tail=20

echo.
echo 6. Description des pods en erreur:
for /f %%i in ('kubectl get pods --field-selector=status.phase!=Running -o name 2^>nul') do (
    echo === %%i ===
    kubectl describe %%i
)

echo.
echo 7. Test de connectivite interne:
kubectl run test-pod --image=busybox --rm -it --restart=Never -- /bin/sh -c "nslookup frontend-service && nslookup backend-service"