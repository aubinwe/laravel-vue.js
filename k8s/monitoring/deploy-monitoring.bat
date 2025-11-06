@echo off
echo ========================================
echo   DEPLOIEMENT MONITORING
echo ========================================

echo.
echo 1. Deploiement du namespace monitoring...
kubectl apply -f 01-monitoring-namespace.yaml

echo.
echo 2. Deploiement de Prometheus...
kubectl apply -f 02-prometheus-config.yaml
kubectl apply -f 03-prometheus.yaml

echo.
echo 3. Deploiement de Grafana...
kubectl apply -f 05-grafana-dashboards.yaml
kubectl apply -f 04-grafana.yaml

echo.
echo 4. Deploiement de l'Ingress...
kubectl apply -f 06-monitoring-ingress.yaml

echo.
echo 5. Attente du demarrage...
kubectl wait --for=condition=ready pod -l app=prometheus -n monitoring --timeout=300s
kubectl wait --for=condition=ready pod -l app=grafana -n monitoring --timeout=300s

echo.
echo 6. Verification du statut...
kubectl get pods -n monitoring
kubectl get services -n monitoring

echo.
echo ========================================
echo   ACCES AUX OUTILS
echo ========================================
echo.
echo Ajoutez a votre fichier hosts:
echo 127.0.0.1 monitoring.local
echo.
echo URLs d'acces:
echo - Grafana: http://monitoring.local/grafana
echo   Login: admin / admin123
echo - Prometheus: http://monitoring.local/prometheus
echo.
echo Dashboards Grafana disponibles:
echo - Gestion Notes - Vue d'ensemble
echo - Kubernetes Cluster
echo.
pause