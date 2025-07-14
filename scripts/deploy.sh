#!/bin/bash

# Script de déploiement Kubernetes
echo "Déploiement de l'application Coach Vitrine sur Kubernetes"

# Vérifier que kubectl est disponible
if ! command -v kubectl &> /dev/null; then
    echo "kubectl n'est pas installé ou n'est pas dans le PATH"
    exit 1
fi

# Vérifier la connexion au cluster
echo "Vérification de la connexion au cluster..."
kubectl cluster-info
if [ $? -ne 0 ]; then
    echo "Impossible de se connecter au cluster Kubernetes"
    exit 1
fi

# Créer les namespaces
echo "Création des namespaces..."
kubectl apply -f k8s/namespaces/namespaces.yaml

# Créer les secrets
echo "Création des secrets..."
kubectl apply -f k8s/secrets/secrets.yaml

# Créer les configmaps
echo "Création des configmaps..."
kubectl apply -f k8s/configmaps/configmaps.yaml

# Créer les volumes
echo "Création des volumes persistants..."
kubectl apply -f k8s/volumes/postgres-volume.yaml

# Attendre que le PVC soit bound
echo "Attente que le PVC soit bound..."
kubectl wait --for=condition=Bound pvc/postgres-pvc -n coach-vitrine --timeout=60s

# Déployer PostgreSQL en premier
echo "Déploiement de PostgreSQL..."
kubectl apply -f k8s/deployments/postgres-deployment.yaml
kubectl apply -f k8s/services/services.yaml

# Attendre que PostgreSQL soit prêt
echo "Attente que PostgreSQL soit prêt..."
kubectl wait --for=condition=Ready pod -l app=postgres -n coach-vitrine --timeout=300s

# Déployer les services backend
echo "Déploiement des services backend..."
kubectl apply -f k8s/deployments/backend-deployments.yaml

# Attendre que les services backend soient prêts
echo "Attente que les services backend soient prêts..."
kubectl wait --for=condition=Ready pod -l app=users-service -n coach-vitrine --timeout=300s
kubectl wait --for=condition=Ready pod -l app=posts-service -n coach-vitrine --timeout=300s

# Déployer le frontend
echo "Déploiement du frontend..."
kubectl apply -f k8s/deployments/frontend-deployment.yaml

# Attendre que le frontend soit prêt
echo "Attente que le frontend soit prêt..."
kubectl wait --for=condition=Ready pod -l app=frontend -n coach-vitrine --timeout=300s

# Déployer l'ingress
echo "Configuration de l'ingress..."
kubectl apply -f k8s/ingress/ingress.yaml

echo "Déploiement terminé avec succès!"
echo ""
echo "État des pods:"
kubectl get pods -n coach-vitrine
echo ""
echo "Services:"
kubectl get services -n coach-vitrine
echo ""
echo "Ingress:"
kubectl get ingress -n coach-vitrine
echo ""
echo "Application accessible sur: http://app.local"
echo "N'oubliez pas d'ajouter '127.0.0.1 app.local' à votre fichier /etc/hosts"
