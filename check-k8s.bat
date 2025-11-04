@echo off
echo === DIAGNOSTIC KUBERNETES ===

echo 1. Statut des pods:
kubectl get pods -n gestion-notes -o wide

echo.
echo 2. Statut des services:
kubectl get services -n gestion-notes

echo.
echo 3. Logs des pods en erreur:
for /f %%i in ('kubectl get pods -n gestion-notes --field-selector=status.phase!=Running -o name 2^>nul') do (
    echo === LOGS %%i ===
    kubectl logs %%i -n gestion-notes --tail=10
)

echo.
echo 4. Test de connectivite:
curl -s http://localhost:30000 > nul && echo "Frontend OK" || echo "Frontend KO"
curl -s http://localhost:30001/api/health > nul && echo "Backend OK" || echo "Backend KO"

pause