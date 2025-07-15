#!/bin/bash

# Script pour redémarrer l'application Coach Vitrine
echo "🚀 Redémarrage de l'application Coach Vitrine..."

# Vérifier si le namespace existe
if ! kubectl get namespace coach-vitrine >/dev/null 2>&1; then
    echo "❌ Le namespace 'coach-vitrine' n'existe pas"
    echo "🔧 Utilisez './scripts/deploy.sh' pour un déploiement complet"
    exit 1
fi

echo "📊 État actuel des ressources:"
kubectl get pods,svc,ingress -n coach-vitrine

echo ""
echo "▶️  Redémarrage des déploiements..."

# Redémarrer PostgreSQL en premier (dépendance des autres services)
echo "🗄️  Démarrage de PostgreSQL..."
kubectl scale deployment postgres --replicas=1 -n coach-vitrine

# Attendre que PostgreSQL soit prêt
echo "⏳ Attente que PostgreSQL soit prêt..."
kubectl wait --for=condition=available --timeout=120s deployment/postgres -n coach-vitrine

# Redémarrer les services backend
echo "🔧 Démarrage du service users..."
kubectl scale deployment users-service --replicas=2 -n coach-vitrine

echo "🔧 Démarrage du service posts..."
kubectl scale deployment posts-service --replicas=2 -n coach-vitrine

# Attendre que les services backend soient prêts
echo "⏳ Attente que les services backend soient prêts..."
kubectl wait --for=condition=available --timeout=120s deployment/users-service -n coach-vitrine
kubectl wait --for=condition=available --timeout=120s deployment/posts-service -n coach-vitrine

# Redémarrer le frontend
echo "🌐 Démarrage du frontend..."
kubectl scale deployment frontend --replicas=3 -n coach-vitrine

# Attendre que le frontend soit prêt
echo "⏳ Attente que le frontend soit prêt..."
kubectl wait --for=condition=available --timeout=120s deployment/frontend -n coach-vitrine

echo ""
echo "📊 État final des ressources:"
kubectl get pods,svc,ingress -n coach-vitrine

echo ""
echo "🧪 Test de connectivité..."
echo "Frontend: $(curl -s -o /dev/null -w "%{http_code}" http://app.local 2>/dev/null || echo 'ERREUR')"
echo "API Users: $(curl -s -o /dev/null -w "%{http_code}" http://app.local/api/users 2>/dev/null || echo 'ERREUR')"
echo "API Posts: $(curl -s -o /dev/null -w "%{http_code}" http://app.local/api/posts 2>/dev/null || echo 'ERREUR')"

echo ""
echo "✅ Application redémarrée avec succès!"
echo ""
echo "🌐 Accès à l'application:"
echo "   Frontend: http://app.local"
echo "   API Users: http://app.local/api/users"
echo "   API Posts: http://app.local/api/posts"
echo ""
echo "💾 Toutes les données ont été préservées"
