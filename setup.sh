#!/bin/bash

# Script pour rendre tous les scripts exécutables
echo "Configuration des permissions des scripts..."

chmod +x scripts/build-images.sh
chmod +x scripts/deploy.sh
chmod +x scripts/monitor.sh
chmod +x scripts/cleanup.sh

echo "Scripts configurés:"
ls -la scripts/*.sh

echo ""
echo "Vous pouvez maintenant exécuter:"
echo "  ./scripts/build-images.sh  - Construire les images Docker"
echo "  ./scripts/deploy.sh        - Déployer sur Kubernetes"
echo "  ./scripts/monitor.sh       - Monitoring de l'application"
echo "  ./scripts/cleanup.sh       - Nettoyer l'environnement"
