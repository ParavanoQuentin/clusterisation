# Tests de Haute Disponibilité - Coach Vitrine

## Objectifs des tests

Ce document détaille les procédures de test pour valider:
1. La scalabilité (scale up/down)
2. La résilience (kill pod/container)
3. La haute disponibilité
4. La persistence des données
5. Le load balancing

## Prérequis

```bash
# Vérifier que l'### Critères de Validation

### Tests réussis si:
- Tous les pods se recréent automatiquement après suppression
- L'application reste accessible pendant le scaling
- Les données persistent après redémarrage de PostgreSQL
- Le load balancing distribue correctement les requêtes
- Aucune perte de données durant les tests
- Temps de récupération < 30 secondes pour les pods applicatifs
- Temps de récupération < 60 secondes pour PostgreSQL

### Tests échoués si:
- Pods ne se recréent pas automatiquement
- Interruption de service pendant les opérations
- Perte de données
- Temps de récupération > seuils définis
- Erreurs persistantes dans les logséployée
kubectl get pods -n coach-vitrine

# Installer des outils de test (optionnel)
# Apache Bench
sudo apt-get install apache2-utils

# curl pour les tests d'API
curl --version
```

## Test 1: Scalabilité (Scale Up/Down)

### 1.1 Scale Up - Augmenter le nombre de replicas

```bash
# État initial
kubectl get pods -n coach-vitrine

# Scale up frontend (3 -> 6 replicas)
kubectl scale deployment frontend --replicas=6 -n coach-vitrine

# Scale up users-service (2 -> 4 replicas)
kubectl scale deployment users-service --replicas=4 -n coach-vitrine

# Scale up posts-service (2 -> 4 replicas)
kubectl scale deployment posts-service --replicas=4 -n coach-vitrine

# Vérifier le scaling
kubectl get pods -n coach-vitrine -w
```

**Capture d'écran attendue**: Plus de pods en état "Running"

### 1.2 Scale Down - Réduire le nombre de replicas

```bash
# Scale down frontend (6 -> 2 replicas)
kubectl scale deployment frontend --replicas=2 -n coach-vitrine

# Scale down users-service (4 -> 1 replica)
kubectl scale deployment users-service --replicas=1 -n coach-vitrine

# Vérifier le scaling
kubectl get pods -n coach-vitrine
```

**Résultat attendu**: Réduction automatique des pods, application toujours accessible

### 1.3 Test de charge pendant le scaling

```bash
# Terminal 1: Lancer un test de charge
while true; do
  curl -s http://app.local/api/users > /dev/null
  echo "$(date): API Users OK"
  sleep 1
done

# Terminal 2: Effectuer le scaling
kubectl scale deployment users-service --replicas=5 -n coach-vitrine
```

**Résultat attendu**: Aucune interruption de service pendant le scaling

## Test 2: Résilience - Kill Pod/Container

### 2.1 Supprimer un pod frontend

```bash
# Lister les pods frontend
kubectl get pods -l app=frontend -n coach-vitrine

# Supprimer un pod spécifique
kubectl delete pod <frontend-pod-name> -n coach-vitrine

# Observer la recréation automatique
kubectl get pods -l app=frontend -n coach-vitrine -w
```

**Résultat attendu**: 
- Pod recréé automatiquement
- Application reste accessible
- Aucune perte de service

### 2.2 Supprimer un pod de service backend

```bash
# Supprimer un pod users-service
kubectl get pods -l app=users-service -n coach-vitrine
kubectl delete pod <users-service-pod-name> -n coach-vitrine

# Tester l'API pendant la recréation
curl http://app.local/api/users
```

**Résultat attendu**: 
- Load balancer redirige vers les autres pods
- Service continue de fonctionner

### 2.3 Supprimer le pod PostgreSQL

```bash
# Avant suppression: noter les données
curl http://app.local/api/users | jq .

# Supprimer le pod PostgreSQL
kubectl delete pod -l app=postgres -n coach-vitrine

# Attendre la recréation
kubectl wait --for=condition=Ready pod -l app=postgres -n coach-vitrine --timeout=300s

# Vérifier la persistence des données
curl http://app.local/api/users | jq .
```

**Résultat attendu**: 
- Données conservées après redémarrage
- Services backend se reconnectent automatiquement

## Test 3: Test de Charge et Load Balancing

### 3.1 Test de charge avec Apache Bench

```bash
# Test sur le frontend
ab -n 1000 -c 10 http://app.local/

# Test sur l'API users
ab -n 500 -c 5 http://app.local/api/users

# Test sur l'API posts
ab -n 500 -c 5 http://app.local/api/posts
```

### 3.2 Vérification du load balancing

```bash
# Script de test du load balancing
for i in {1..20}; do
  curl -s http://app.local/api/users/health | jq -r '.timestamp'
  sleep 0.1
done
```

**Observation**: Les requêtes doivent être distribuées entre les différents pods

### 3.3 Logs de load balancing

```bash
# Observer les logs des différents pods
kubectl logs -l app=users-service -n coach-vitrine --tail=50

# Ou en temps réel
kubectl logs -l app=users-service -n coach-vitrine -f
```

## Test 4: Tests de Défaillance Réseau

### 4.1 Isoler temporairement un nœud

```bash
# Simuler une panne réseau (drain node)
kubectl get nodes
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Observer la migration des pods
kubectl get pods -n coach-vitrine -o wide

# Restaurer le nœud
kubectl uncordon <node-name>
```

### 4.2 Test de timeout de base de données

```bash
# Bloquer temporairement l'accès à PostgreSQL
kubectl patch deployment postgres -n coach-vitrine -p '{"spec":{"replicas":0}}'

# Tester la réponse des APIs
curl -v http://app.local/api/users

# Restaurer PostgreSQL
kubectl patch deployment postgres -n coach-vitrine -p '{"spec":{"replicas":1}}'
```

## Test 5: Tests de Performance

### 5.1 Monitoring des ressources

```bash
# Utilisation CPU/Mémoire des pods
kubectl top pods -n coach-vitrine

# Utilisation des nœuds
kubectl top nodes
```

### 5.2 Test de montée en charge progressive

```bash
#!/bin/bash
# Script de test progressif

for concurrent in 1 5 10 20 50; do
  echo "Test avec $concurrent utilisateurs concurrents"
  ab -n 1000 -c $concurrent http://app.local/api/users
  sleep 5
done
```

## Test 6: Tests de Sécurité

### 6.1 Vérification des secrets

```bash
# Les secrets ne doivent pas être lisibles en plain text
kubectl get secret postgres-secret -n coach-vitrine -o yaml

# Vérifier l'utilisation des secrets dans les pods
kubectl describe pod -l app=users-service -n coach-vitrine
```

### 6.2 Test d'accès aux services internes

```bash
# Tentative d'accès direct aux services (doit échouer)
curl http://users-service.coach-vitrine.svc.cluster.local:3001/health

# Accès via ingress (doit fonctionner)
curl http://app.local/api/users
```

## Commandes de Test Pratiques

### Script de test complet

```bash
#!/bin/bash
# test-ha.sh - Script de test de haute disponibilité

echo "Tests de Haute Disponibilité - Coach Vitrine"

# Test 1: Vérifier l'état initial
echo "État initial:"
kubectl get pods -n coach-vitrine

# Test 2: Scale up
echo "Scale up..."
kubectl scale deployment frontend --replicas=5 -n coach-vitrine
kubectl scale deployment users-service --replicas=3 -n coach-vitrine
sleep 30

# Test 3: Test de charge
echo "Test de charge..."
ab -n 100 -c 5 http://app.local/ > /dev/null 2>&1

# Test 4: Kill random pod
echo "Suppression d'un pod aléatoire..."
POD=$(kubectl get pods -l app=frontend -n coach-vitrine -o name | head -1)
kubectl delete $POD -n coach-vitrine

# Test 5: Vérifier la récupération
echo "Vérification de la récupération..."
sleep 10
kubectl get pods -n coach-vitrine

# Test 6: Scale down
echo "Scale down..."
kubectl scale deployment frontend --replicas=3 -n coach-vitrine
kubectl scale deployment users-service --replicas=2 -n coach-vitrine

echo "Tests terminés!"
```

## Métriques à Observer

### 1. Temps de récupération
- Temps de recréation d'un pod supprimé
- Temps de scaling up/down
- Temps de démarrage des services

### 2. Disponibilité
- Pourcentage de requêtes réussies
- Temps de réponse pendant les pannes
- Continuité de service

### 3. Persistence
- Conservation des données après redémarrage
- Intégrité des données
- Temps de reconnexion aux services

## Captures d'Écran Recommandées

1. **État initial des pods**
   ```bash
   kubectl get pods -n coach-vitrine -o wide
   ```

2. **Scaling en action**
   ```bash
   kubectl get pods -n coach-vitrine -w
   ```

3. **Tests de charge**
   ```bash
   ab -n 1000 -c 10 http://app.local/
   ```

4. **Logs de récupération**
   ```bash
   kubectl logs -l app=frontend -n coach-vitrine --tail=20
   ```

5. **Monitoring des ressources**
   ```bash
   kubectl top pods -n coach-vitrine
   ```

## Critères de Validation

### ✅ Tests réussis si:
- Tous les pods se recréent automatiquement après suppression
- L'application reste accessible pendant le scaling
- Les données persistent après redémarrage de PostgreSQL
- Le load balancing distribue correctement les requêtes
- Aucune perte de données durant les tests
- Temps de récupération < 30 secondes pour les pods applicatifs
- Temps de récupération < 60 secondes pour PostgreSQL

### ❌ Tests échoués si:
- Pods ne se recréent pas automatiquement
- Interruption de service pendant les opérations
- Perte de données
- Temps de récupération > seuils définis
- Erreurs persistantes dans les logs
