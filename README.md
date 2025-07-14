# Projet de Clusterisation - Site Vitrine Coach

## Architecture

Ce projet implémente un site vitrine pour coach avec une architecture microservices :

- **Frontend** : React SPA (3 replicas)
- **Backend** : 2 microservices Node.js/Express
  - Service Users (2 replicas)
  - Service Posts (2 replicas)
- **Base de données** : PostgreSQL (1 replica avec persistance)

## Structure du projet

```
clusterisation/
├── frontend/                 # Application React
├── backend/
│   ├── users-service/       # Microservice de gestion des utilisateurs
│   └── posts-service/       # Microservice de gestion des posts
├── database/                # Scripts et configuration PostgreSQL
├── k8s/                     # Manifests Kubernetes
│   ├── namespaces/
│   ├── secrets/
│   ├── configmaps/
│   ├── volumes/
│   ├── deployments/
│   ├── services/
│   └── ingress/
├── docker/                  # Dockerfiles
└── docs/                    # Documentation et tutoriels
```

## Installation et déploiement

Voir le fichier `docs/INSTALLATION.md` pour les instructions détaillées.

## Tests de haute disponibilité

Voir le fichier `docs/TESTS.md` pour les procédures de test.
