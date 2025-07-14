# Documentation Complète - Projet Coach Vitrine

## Vue d'ensemble du projet

Ce projet implémente une application complète de site vitrine pour coach avec une architecture microservices, orchestrée par Kubernetes. Il répond à tous les critères du cahier des charges pour le cours de clusterisation de containers.

## Architecture

### Stack technique
- **Frontend**: React SPA avec Nginx (3 replicas)
- **Backend**: 2 microservices Node.js/Express
  - Service Users (2 replicas) - Port 3001
  - Service Posts (2 replicas) - Port 3002
- **Base de données**: PostgreSQL (1 replica avec persistance)
- **Orchestration**: Kubernetes (k3s recommandé)
- **Load Balancer**: Ingress NGINX
- **Monitoring**: Scripts de monitoring personnalisés

### Fonctionnalités implémentées

#### Parties obligatoires
1. **Cluster Kubernetes** - Configuration 1 master + 2 workers possible
2. **Services conteneurisés** - Tous les composants dockerisés
3. **Déploiements séparés** - Manifests organisés par namespace
4. **Réplication** - Frontend (3), Backend (2×2), DB (1)
5. **Persistence** - PV/PVC pour PostgreSQL
6. **Sécurité** - Secrets, ConfigMaps, RBAC
7. **Exposition** - Ingress avec load balancing
8. **HTTPS** - Support certificats auto-signés

#### Fonctionnalités bonus
1. **NetworkPolicy** - Sécurisation du trafic réseau
2. **Autoscaling** - HPA sur CPU/Memory
3. **Helm Charts** - Déploiement simplifié
4. **Monitoring** - Scripts de surveillance
5. **RBAC** - Contrôle d'accès basé sur les rôles

## Structure du projet

```
clusterisation/
├── README.md                          # Vue d'ensemble
├── frontend/                          # Application React
│   ├── src/
│   │   ├── components/               # Composants React
│   │   ├── App.js                    # Application principale
│   │   └── index.js                  # Point d'entrée
│   └── package.json                  # Dépendances React
├── backend/
│   ├── users-service/                # Microservice utilisateurs
│   │   ├── server.js                 # Serveur Express
│   │   └── package.json              # Dépendances Node.js
│   └── posts-service/                # Microservice articles
│       ├── server.js                 # Serveur Express
│       └── package.json              # Dépendances Node.js
├── docker/                           # Dockerfiles
│   ├── frontend/
│   │   ├── Dockerfile                # Image frontend
│   │   └── nginx.conf                # Configuration Nginx
│   ├── users-service/
│   │   └── Dockerfile                # Image users-service
│   └── posts-service/
│       └── Dockerfile                # Image posts-service
├── k8s/                              # Manifests Kubernetes
│   ├── namespaces/
│   │   └── namespaces.yaml           # Namespaces
│   ├── secrets/
│   │   └── secrets.yaml              # Secrets (DB, JWT)
│   ├── configmaps/
│   │   └── configmaps.yaml           # Configuration non sensible
│   ├── volumes/
│   │   └── postgres-volume.yaml      # PV/PVC PostgreSQL
│   ├── deployments/
│   │   ├── postgres-deployment.yaml  # Déploiement PostgreSQL
│   │   ├── backend-deployments.yaml  # Déploiements backend
│   │   └── frontend-deployment.yaml  # Déploiement frontend
│   ├── services/
│   │   └── services.yaml             # Services Kubernetes
│   ├── ingress/
│   │   └── ingress.yaml              # Ingress avec TLS
│   ├── autoscaling/
│   │   └── hpa.yaml                  # Horizontal Pod Autoscaler
│   └── security/
│       ├── network-policies.yaml     # Politiques réseau
│       └── rbac.yaml                 # RBAC
├── helm/                             # Charts Helm
│   └── coach-vitrine/
│       ├── Chart.yaml                # Métadonnées du chart
│       ├── values.yaml               # Valeurs par défaut
│       └── templates/                # Templates Kubernetes
├── scripts/                          # Scripts d'automatisation
│   ├── build-images.sh/.bat          # Construction images Docker
│   ├── deploy.sh/.bat                # Déploiement Kubernetes
│   ├── monitor.sh/.bat               # Monitoring
│   └── cleanup.sh                    # Nettoyage
└── docs/                             # Documentation
    ├── INSTALLATION.md               # Guide d'installation
    ├── TESTS.md                      # Procédures de test
    └── ARCHITECTURE.md               # Ce document
```

## Installation rapide

### 1. Construction des images
```bash
# Linux/Mac
./scripts/build-images.sh

# Windows
scripts\build-images.bat
```

### 2. Déploiement
```bash
# Linux/Mac
./scripts/deploy.sh

# Windows
scripts\deploy.bat
```

### 3. Configuration DNS
```bash
# Ajouter à /etc/hosts (Linux/Mac) ou C:\Windows\System32\drivers\etc\hosts (Windows)
127.0.0.1 app.local
```

### 4. Accès à l'application
- **Frontend**: http://app.local
- **API Users**: http://app.local/api/users
- **API Posts**: http://app.local/api/posts

## Configuration avancée

### Helm (optionnel)
```bash
# Installer avec Helm
helm install coach-vitrine ./helm/coach-vitrine

# Mise à jour
helm upgrade coach-vitrine ./helm/coach-vitrine

# Désinstallation
helm uninstall coach-vitrine
```

### Autoscaling
```bash
# Activer les HPA
kubectl apply -f k8s/autoscaling/hpa.yaml

# Vérifier
kubectl get hpa -n coach-vitrine
```

### Sécurité renforcée
```bash
# Appliquer les NetworkPolicies
kubectl apply -f k8s/security/network-policies.yaml

# Appliquer RBAC
kubectl apply -f k8s/security/rbac.yaml
```

## Tests de validation

### Tests de haute disponibilité
Voir `docs/TESTS.md` pour les procédures complètes.

```bash
# Test rapide de scaling
kubectl scale deployment frontend --replicas=5 -n coach-vitrine

# Test de résilience
kubectl delete pod -l app=users-service -n coach-vitrine

# Monitoring
./scripts/monitor.sh
```

## Monitoring et observabilité

### Scripts de monitoring
```bash
# Monitoring en temps réel
./scripts/monitor.sh

# Logs des services
kubectl logs -f -l app=users-service -n coach-vitrine
```

### Métriques importantes
- Nombre de pods Running/Ready
- Utilisation CPU/Memory
- Temps de réponse des APIs
- Disponibilité des services

## Sécurité

### Secrets gérés
- Identifiants PostgreSQL (Base64)
- Clés JWT pour l'authentification
- Certificats TLS (optionnel)

### Mesures de sécurité
- Containers non-root
- Network Policies
- RBAC (Role-Based Access Control)
- Secrets séparés des ConfigMaps
- Health checks sur tous les services

## Exposition et réseau

### Ingress Controller
- NGINX Ingress pour le load balancing
- Support HTTPS avec certificats auto-signés
- Redirection des APIs vers les bons services

### Services internes
- Communication inter-services via DNS interne
- Load balancing automatique par Kubernetes
- Isolation réseau par namespace

## Scalabilité

### Horizontal Pod Autoscaler (HPA)
- Frontend: 3-10 replicas (CPU 70%, Memory 80%)
- Users Service: 2-8 replicas (CPU 70%, Memory 80%)
- Posts Service: 2-8 replicas (CPU 70%, Memory 80%)

### Scaling manuel
```bash
# Augmenter les replicas
kubectl scale deployment frontend --replicas=6 -n coach-vitrine

# Vérifier le scaling
kubectl get pods -n coach-vitrine -w
```

## Persistence et sauvegarde

### Volumes persistants
- PostgreSQL: PV de 5Gi avec stockage local
- Survit aux redémarrages et suppressions de pods
- Localisation: `/data/postgres` sur l'hôte

### Stratégie de sauvegarde
```bash
# Sauvegarde manuelle de la DB
kubectl exec -it postgres-xxx -n coach-vitrine -- pg_dump -U postgres coach_vitrine > backup.sql

# Restauration
kubectl exec -i postgres-xxx -n coach-vitrine -- psql -U postgres coach_vitrine < backup.sql
```

## Dépannage

### Problèmes courants

1. **Images non trouvées**
   ```bash
   # Vérifier les images
   docker images | grep coach-vitrine
   
   # Pour minikube
   minikube image load coach-vitrine/frontend:latest
   ```

2. **PVC en attente**
   ```bash
   # Créer le répertoire de données
   sudo mkdir -p /data/postgres
   sudo chmod 777 /data/postgres
   ```

3. **Services inaccessibles**
   ```bash
   # Port-forward temporaire
   kubectl port-forward service/frontend-service 8080:80 -n coach-vitrine
   ```

### Logs utiles
```bash
# Logs des composants
kubectl logs -l app=postgres -n coach-vitrine
kubectl logs -l app=users-service -n coach-vitrine
kubectl logs -l app=posts-service -n coach-vitrine
kubectl logs -l app=frontend -n coach-vitrine

# Événements du namespace
kubectl get events -n coach-vitrine --sort-by=.metadata.creationTimestamp
```

## Checklist de validation

### Critères obligatoires validés
- [x] Cluster Kubernetes fonctionnel
- [x] Frontend React (3 replicas)
- [x] Backend microservices (2×2 replicas)
- [x] Base de données PostgreSQL (1 replica)
- [x] Dockerfiles pour tous les composants
- [x] Manifests Kubernetes organisés
- [x] Persistence des données (PV/PVC)
- [x] Secrets et ConfigMaps
- [x] Ingress/Load Balancer
- [x] Tests de haute disponibilité
- [x] Documentation complète

### Bonus implémentés
- [x] NetworkPolicy
- [x] Autoscaling (HPA)
- [x] Helm Charts
- [x] RBAC
- [x] Scripts d'automatisation
- [x] Monitoring

## Conclusion

Ce projet implémente une solution complète de clusterisation respectant tous les critères du cahier des charges. L'architecture microservices permet une scalabilité horizontale, la persistence assure la durabilité des données, et les mesures de sécurité protègent l'application en production.

L'application démontre les concepts clés de l'orchestration de containers avec Kubernetes, incluant la haute disponibilité, le load balancing, et la gestion des secrets dans un environnement distribué.
