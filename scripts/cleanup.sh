#!/bin/bash

# Script de nettoyage complet
echo "Nettoyage de l'environnement Coach Vitrine"

# Supprimer les déploiements
echo "Suppression des déploiements..."
kubectl delete namespace coach-vitrine --ignore-not-found

# Supprimer les PV (si nécessaire)
echo "Suppression des volumes persistants..."
kubectl delete pv postgres-pv --ignore-not-found

# Supprimer les images Docker (optionnel)
read -p "Voulez-vous supprimer les images Docker? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Suppression des images Docker..."
    docker rmi coach-vitrine/frontend:latest 2>/dev/null || true
    docker rmi coach-vitrine/users-service:latest 2>/dev/null || true
    docker rmi coach-vitrine/posts-service:latest 2>/dev/null || true
fi

# Nettoyer les ressources orphelines
echo "Nettoyage des ressources orphelines..."
kubectl delete all --all -n coach-vitrine-monitoring --ignore-not-found
kubectl delete namespace coach-vitrine-monitoring --ignore-not-found

echo "Nettoyage terminé!"
echo "Pour supprimer le répertoire /data/postgres, exécutez:"
echo "   sudo rm -rf /data/postgres"
