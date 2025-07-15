# 🚀 Projet Coach Vitrine - Architecture Microservices sur Kubernetes

## 📋 Vue d'ensemble

Le projet **Coach Vitrine** est une application web complète déployée sur Kubernetes, utilisant une architecture microservices moderne. Cette application permet de présenter des coachs sportifs et leurs articles de blog à travers une interface web React et des APIs REST.

---

## 🏗️ Architecture du Cluster Kubernetes

### Configuration Cluster

- **Type** : Docker Desktop Kubernetes (développement local)
- **Version** : v1.32.2
- **Nodes** : 1 node (docker-desktop) avec rôle control-plane
- **Namespace** : `coach-vitrine` (isolation des ressources)

### Composants déployés

```txt
📦 Cluster Kubernetes
├── 🎛️  Control Plane (docker-desktop)
├── 🔧  NGINX Ingress Controller v1.8.1
└── 📁  Namespace: coach-vitrine
    ├── 🌐 Frontend (React) - 3 replicas
    ├── 👥 Users Service (Node.js) - 2 replicas
    ├── 📝 Posts Service (Node.js) - 2 replicas
    └── 🗄️  PostgreSQL Database - 1 replica
```

---

## 🚀 Déploiement des Services

### 🌐 Frontend (React)

- **Image** : `coach-vitrine-frontend:latest`
- **Replicas** : 3 instances pour la haute disponibilité
- **Port** : 80 (NGINX servant les fichiers statiques)
- **Ressources** : Interface utilisateur optimisée et responsive

### 👥 Users Service (Microservice)

- **Image** : `coach-vitrine-users:latest`
- **Replicas** : 2 instances
- **Port** : 3001
- **API** : `/api/users` - Gestion des profils de coachs
- **Données** : 5 coachs avec spécialités (Fitness, Nutrition, Yoga, Course, CrossFit)

### 📝 Posts Service (Microservice)

- **Image** : `coach-vitrine-posts:latest`
- **Replicas** : 2 instances
- **Port** : 3002
- **API** : `/api/posts` - Gestion des articles de blog
- **Données** : 6 articles thématiques sur le coaching sportif

### 🗄️ Base de Données PostgreSQL

- **Image** : `postgres:13`
- **Replicas** : 1 instance (mode single pour la démo)
- **Port** : 5432
- **Bases** : `users_db` et `posts_db`

---

## 💾 Persistance des Données

### Volumes Persistants

```yaml
PersistentVolume: postgres-pv
├── Capacité: 5Gi
├── Mode d'accès: ReadWriteOnce (RWO)
├── Politique: Retain (conservation des données)
└── Stockage: Local (Docker Desktop)

PersistentVolumeClaim: postgres-pvc
├── Volume lié: postgres-pv
├── Statut: Bound (correctement attaché)
└── Montage: /var/lib/postgresql/data
```

### Garantie de Survie

- ✅ **Redémarrage de pods** : Les données PostgreSQL survivent
- ✅ **Redémarrage de cluster** : Volume persistant conservé
- ✅ **Mise à jour d'application** : Base de données intacte
- ✅ **Rollback de déploiement** : Données préservées

---

## 🔒 Sécurité

### Gestion des Secrets

```yaml
Secret: postgres-secret (Type: Opaque)
├── POSTGRES_DB: coaches_db
├── POSTGRES_USER: coach_admin
└── POSTGRES_PASSWORD: [encrypted]

Secret: app-secrets (Type: Opaque)
└── DATABASE_URL: [connection string sécurisée]
```

### Mesures de Sécurité Implémentées

#### 🛡️ Secrets Management

- **Chiffrement** : Secrets stockés de façon chiffrée dans etcd
- **Injection sécurisée** : Variables d'environnement via secrets
- **Isolation** : Accès limité aux pods autorisés uniquement

#### 🔐 HTTPS/TLS (Configuration disponible)

```yaml
TLS Configuration (disponible dans ingress.yaml):
├── 📜 Certificats auto-signés (cert-manager)
├── 🔄 Redirection HTTP → HTTPS
├── 🚀 Force SSL Redirect
└── 🔑 Secret TLS: coach-vitrine-tls
```

#### 🔒 Sécurité réseau

- **Network Policies** : Isolation du trafic réseau
- **RBAC** : Contrôle d'accès basé sur les rôles
- **Service Accounts** : Identités dédiées pour chaque service

#### 🛡️ Sécurité des containers

- **Headers de sécurité** : CSP, X-Frame-Options, HSTS
- **Images** : Basées sur des images officielles (Node.js, PostgreSQL)
- **Principe du moindre privilège** : Containers non-root quand possible

---

## 🌐 Exposition et Accès

### Load Balancer / Ingress

```yaml
NGINX Ingress Controller:
├── 🎯 Classe: nginx
├── 🔄 Load Balancing automatique
├── 📍 Host: app.local
└── 🛣️  Routes:
    ├── / → frontend-service:80
    ├── /api/users → users-service:3001
    └── /api/posts → posts-service:3002
```

### DNS et Résolution

```bash
Configuration DNS locale:
├── 📋 Fichier hosts: C:\Windows\System32\drivers\etc\hosts
├── 🎯 Entrée: 127.0.0.1 app.local
└── 🔗 Résolution: app.local → localhost → Docker Desktop
```

### Services ClusterIP

```yaml
Services internes (ClusterIP):
├── frontend-service: 10.105.169.117:80
├── users-service: 10.97.239.136:3001
├── posts-service: 10.106.240.81:3002
└── postgres-service: 10.96.51.32:5432
```

---

## 🎯 Points d'Accès

### 🌐 Interface Utilisateur

- **URL** : <http://app.local>
- **Technologie** : React 18 avec interface moderne
- **Fonctionnalités** : Navigation entre coachs et articles

### 🔌 APIs REST

- **Users API** : <http://app.local/api/users>
  - GET : Liste des 5 coachs avec spécialités
- **Posts API** : <http://app.local/api/posts>
  - GET : Liste des 6 articles de blog

---

## 📊 Monitoring et Observabilité

### État du Cluster

- ✅ **8/8 Pods** en état Running
- ✅ **4 Services** opérationnels
- ✅ **1 Ingress** configuré avec succès
- ✅ **2 Secrets** déployés et sécurisés
- ✅ **1 PVC** attaché et fonctionnel

### Santé des Services

```bash
# Vérification rapide
curl http://app.local              # Frontend ✅
curl http://app.local/api/users    # Users API ✅
curl http://app.local/api/posts    # Posts API ✅
```

---

## 🚀 Scripts d'Automatisation

### Build et Déploiement

- **`scripts/build-images.sh`** : Construction des images Docker
- **`scripts/deploy.sh`** : Déploiement complet sur Kubernetes
- **`scripts/cleanup.sh`** : Nettoyage des ressources
- **`scripts/monitor.sh`** : Surveillance des ressources

### Commandes Utiles

```bash
# Construire toutes les images
./scripts/build-images.sh

# Déployer l'application complète
./scripts/deploy.sh

# Surveiller les ressources
./scripts/monitor.sh

# Nettoyer le déploiement
./scripts/cleanup.sh
```

---

## 🎉 Résultat Final

L'application **Coach Vitrine** est maintenant :

- 🟢 **Accessible** via <http://app.local>
- 🟢 **Scalable** avec plusieurs replicas par service
- 🟢 **Résiliente** avec persistance des données
- 🟢 **Sécurisée** avec gestion des secrets
- 🟢 **Monitorable** avec visibilité complète
- 🟢 **Maintenable** avec architecture microservices

Cette architecture démontre une mise en œuvre complète des bonnes pratiques Kubernetes pour une application moderne en production.
