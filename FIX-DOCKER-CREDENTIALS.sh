#!/bin/bash

echo "=== CORRECTION DOCKER CREDENTIALS ==="

# Logout et login Docker
echo "Reset Docker credentials..."
docker logout
docker login

# Pull des images nécessaires
echo "Pull des images de base..."
docker pull node:18-alpine
docker pull nginx:alpine
docker pull php:8.2-apache
docker pull composer:latest
docker pull mysql:8.0
docker pull prom/prometheus:latest
docker pull grafana/grafana:latest

# Vérifier les images
echo "Images disponibles:"
docker images | grep -E "(node|nginx|php|composer|mysql|prometheus|grafana)"

# Redémarrer Docker daemon si nécessaire
echo "Redémarrage Docker..."
sudo systemctl restart docker 2>/dev/null || echo "Redémarrage manuel requis"

echo "✅ Images prêtes pour le build"