#!/bin/bash

# Script de monitoring simple pour Coach Vitrine
echo "Monitoring Coach Vitrine - $(date)"
echo "=========================================="

# Vérifier l'état du cluster
echo "État du cluster:"
kubectl cluster-info
echo ""

# Vérifier les nœuds
echo "Nœuds du cluster:"
kubectl get nodes -o wide
echo ""

# Vérifier l'état des pods
echo "État des pods:"
kubectl get pods -n coach-vitrine -o wide
echo ""

# Vérifier les services
echo "Services:"
kubectl get services -n coach-vitrine
echo ""

# Vérifier l'ingress
echo "Ingress:"
kubectl get ingress -n coach-vitrine
echo ""

# Vérifier les HPA (si activés)
echo "Horizontal Pod Autoscalers:"
kubectl get hpa -n coach-vitrine 2>/dev/null || echo "Aucun HPA configuré"
echo ""

# Utilisation des ressources
echo "Utilisation des ressources:"
if command -v kubectl top &> /dev/null; then
    echo "Nœuds:"
    kubectl top nodes 2>/dev/null || echo "Metrics-server non disponible"
    echo ""
    echo "Pods:"
    kubectl top pods -n coach-vitrine 2>/dev/null || echo "Metrics-server non disponible"
else
    echo "kubectl top non disponible"
fi
echo ""

# Vérifier la connectivité des services
echo "Tests de connectivité:"

# Test frontend
if curl -s --max-time 5 http://app.local/ > /dev/null; then
    echo "Frontend accessible"
else
    echo "Frontend inaccessible"
fi

# Test API Users
if curl -s --max-time 5 http://app.local/api/users > /dev/null; then
    echo "API Users accessible"
else
    echo "API Users inaccessible"
fi

# Test API Posts
if curl -s --max-time 5 http://app.local/api/posts > /dev/null; then
    echo "API Posts accessible"
else
    echo "API Posts inaccessible"
fi
echo ""

# Vérifier les événements récents
echo "Événements récents (dernières 10 minutes):"
kubectl get events --sort-by=.metadata.creationTimestamp -n coach-vitrine | tail -10
echo ""

# Vérifier les logs d'erreur récents
echo "Erreurs récentes dans les logs:"
echo "Frontend:"
kubectl logs -l app=frontend -n coach-vitrine --since=10m | grep -i error | head -5 || echo "Aucune erreur"

echo "Users Service:"
kubectl logs -l app=users-service -n coach-vitrine --since=10m | grep -i error | head -5 || echo "Aucune erreur"

echo "Posts Service:"
kubectl logs -l app=posts-service -n coach-vitrine --since=10m | grep -i error | head -5 || echo "Aucune erreur"

echo "PostgreSQL:"
kubectl logs -l app=postgres -n coach-vitrine --since=10m | grep -i error | head -5 || echo "Aucune erreur"
echo ""

# Résumé de santé
echo "Résumé de santé:"
TOTAL_PODS=$(kubectl get pods -n coach-vitrine --no-headers | wc -l)
RUNNING_PODS=$(kubectl get pods -n coach-vitrine --no-headers | grep Running | wc -l)
READY_PODS=$(kubectl get pods -n coach-vitrine --no-headers | grep "1/1\|2/2\|3/3" | wc -l)

echo "Pods total: $TOTAL_PODS"
echo "Pods en cours d'exécution: $RUNNING_PODS"
echo "Pods prêts: $READY_PODS"

if [ "$RUNNING_PODS" -eq "$TOTAL_PODS" ] && [ "$READY_PODS" -eq "$TOTAL_PODS" ]; then
    echo "Système en bonne santé"
else
    echo "Problèmes détectés"
fi

echo ""
echo "Monitoring terminé - $(date)"
