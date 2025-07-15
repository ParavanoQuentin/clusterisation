#!/bin/bash

# Script pour arrêter l'application Coach Vitrine sans supprimer les données
echo "🔽 Arrêt de l'application Coach Vitrine..."

# Vérifier si le namespace existe
if ! kubectl get namespace coach-vitrine >/dev/null 2>&1; then
    echo "❌ Le namespace 'coach-vitrine' n'existe pas ou l'application n'est pas déployée"
    exit 1
fi

echo "📊 État actuel des ressources:"
kubectl get pods,svc,ingress -n coach-vitrine

echo ""
echo "🛑 Arrêt des déploiements (les données sont préservées)..."

# Arrêter les déploiements en scalant à 0 replicas
echo "⏹️  Arrêt du frontend..."
kubectl scale deployment frontend --replicas=0 -n coach-vitrine

echo "⏹️  Arrêt du service users..."
kubectl scale deployment users-service --replicas=0 -n coach-vitrine

echo "⏹️  Arrêt du service posts..."
kubectl scale deployment posts-service --replicas=0 -n coach-vitrine

echo "⏹️  Arrêt de PostgreSQL..."
kubectl scale deployment postgres --replicas=0 -n coach-vitrine

# Attendre que tous les pods soient arrêtés
echo "⏳ Attente de l'arrêt de tous les pods..."
kubectl wait --for=delete pod --all -n coach-vitrine --timeout=60s

echo ""
echo "📊 État final des ressources:"
kubectl get pods,svc,ingress -n coach-vitrine

echo ""
echo "✅ Application arrêtée avec succès!"
echo ""
echo "📋 Ressources préservées:"
echo "   🔹 Namespace: coach-vitrine"
echo "   🔹 Services ClusterIP"
echo "   🔹 Ingress et routes"
echo "   🔹 Secrets (postgres-secret, app-secrets)"
echo "   🔹 ConfigMaps"
echo "   🔹 Volumes persistants (PV/PVC)"
echo "   🔹 Images Docker"
echo ""
echo "💾 Les données PostgreSQL sont conservées dans le volume persistant"
echo ""
echo "🚀 Pour redémarrer l'application, utilisez:"
echo "   ./scripts/up.sh"
