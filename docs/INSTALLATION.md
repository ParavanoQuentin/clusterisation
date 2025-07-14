# Guide d'Installation et de Déploiement - Coach Vitrine

## Prérequis

### 1. Installation du cluster Kubernetes

#### Option A: k3s (Recommandé pour Linux)
```bash
# Installation de k3s
curl -sfL https://get.k3s.io | sh -

# Vérifier l'installation
sudo k3s kubectl get nodes
```

#### Option B: minikube (Multi-plateforme)
```bash
# Installation de minikube
# Voir: https://minikube.sigs.k8s.io/docs/start/

# Démarrer minikube
minikube start --driver=docker

# Vérifier l'installation
kubectl get nodes
```

#### Option C: Docker Desktop (Windows/Mac)
1. Installer Docker Desktop
2. Activer Kubernetes dans les paramètres
3. Vérifier avec `kubectl get nodes`

### 2. Outils nécessaires

```bash
# Installer kubectl (si pas déjà fait)
# Windows (chocolatey)
choco install kubernetes-cli

# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Installer Docker
# Voir: https://docs.docker.com/get-docker/
```

### 3. Configuration du cluster multi-nœuds (Optionnel)

Pour respecter l'exigence "1 master + 2 workers":

#### Avec k3s:
```bash
# Sur le master
curl -sfL https://get.k3s.io | sh -s - --cluster-init

# Récupérer le token
sudo cat /var/lib/rancher/k3s/server/node-token

# Sur chaque worker
curl -sfL https://get.k3s.io | K3S_URL=https://MASTER_IP:6443 K3S_TOKEN=NODE_TOKEN sh -
```

## Installation de l'application

### 1. Clone et préparation
```bash
git clone <repository_url>
cd clusterisation
```

### 2. Construction des images Docker

#### Linux/Mac:
```bash
chmod +x scripts/build-images.sh
./scripts/build-images.sh
```

#### Windows:
```cmd
scripts\build-images.bat
```

### 3. Vérification des images
```bash
docker images | grep coach-vitrine
```

Vous devriez voir:
- coach-vitrine/frontend:latest
- coach-vitrine/users-service:latest  
- coach-vitrine/posts-service:latest

### 4. Déploiement sur Kubernetes

#### Linux/Mac:
```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

#### Windows:
```cmd
scripts\deploy.bat
```

### 5. Configuration DNS

Ajouter à votre fichier hosts:

#### Linux/Mac:
```bash
echo "127.0.0.1 app.local" | sudo tee -a /etc/hosts
```

#### Windows:
Éditer `C:\Windows\System32\drivers\etc\hosts` et ajouter:
```
127.0.0.1 app.local
```

### 6. Installation d'un Ingress Controller (si nécessaire)

#### NGINX Ingress Controller:
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
```

#### Traefik (pour k3s):
k3s inclut Traefik par défaut, aucune action nécessaire.

## Vérification du déploiement

### 1. Vérifier les pods
```bash
kubectl get pods -n coach-vitrine
```

Sortie attendue:
```
NAME                             READY   STATUS    RESTARTS   AGE
frontend-xxx                     1/1     Running   0          2m
frontend-yyy                     1/1     Running   0          2m
frontend-zzz                     1/1     Running   0          2m
users-service-xxx                1/1     Running   0          3m
users-service-yyy                1/1     Running   0          3m
posts-service-xxx                1/1     Running   0          3m
posts-service-yyy                1/1     Running   0          3m
postgres-xxx                     1/1     Running   0          5m
```

### 2. Vérifier les services
```bash
kubectl get services -n coach-vitrine
```

### 3. Vérifier l'ingress
```bash
kubectl get ingress -n coach-vitrine
```

### 4. Test de l'application
Ouvrir dans le navigateur: http://app.local

## Accès à l'application

### URLs disponibles:
- **Frontend**: http://app.local
- **API Users**: http://app.local/api/users
- **API Posts**: http://app.local/api/posts

### Health checks:
- Users Service: http://app.local/api/users/../health
- Posts Service: http://app.local/api/posts/../health

## Persistence des données

Les données PostgreSQL sont persistées via:
- **PersistentVolume**: /data/postgres sur l'hôte
- **PersistentVolumeClaim**: postgres-pvc (5Gi)

Les données survivront aux redéploiements et suppressions de pods.

## Sécurité

### Secrets configurés:
- `postgres-secret`: Identifiants de la base de données
- `app-secrets`: Clés JWT et autres secrets d'application

### ConfigMaps:
- Configuration des services (non sensible)
- Variables d'environnement

### HTTPS (Configuration avancée)

Pour activer HTTPS avec certificats auto-signés:

1. Installer cert-manager:
```bash
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.13.0/cert-manager.yaml
```

2. Créer un issuer auto-signé:
```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
```

3. Utiliser l'ingress TLS:
```bash
kubectl apply -f k8s/ingress/ingress.yaml
```

## Dépannage

### Problèmes courants:

1. **Images non trouvées**:
```bash
# Vérifier que les images sont construites
docker images | grep coach-vitrine

# Pour minikube, charger les images:
minikube image load coach-vitrine/frontend:latest
minikube image load coach-vitrine/users-service:latest
minikube image load coach-vitrine/posts-service:latest
```

2. **PVC en attente**:
```bash
# Vérifier les PV disponibles
kubectl get pv

# Pour minikube, créer le répertoire:
minikube ssh 'sudo mkdir -p /data/postgres'
```

3. **Services inaccessibles**:
```bash
# Vérifier les logs
kubectl logs -l app=frontend -n coach-vitrine
kubectl logs -l app=users-service -n coach-vitrine
kubectl logs -l app=posts-service -n coach-vitrine

# Port-forward temporaire
kubectl port-forward service/frontend-service 8080:80 -n coach-vitrine
```

4. **Base de données non accessible**:
```bash
# Vérifier PostgreSQL
kubectl logs -l app=postgres -n coach-vitrine

# Test de connexion
kubectl exec -it postgres-xxx -n coach-vitrine -- psql -U postgres -d coach_vitrine
```

## Commandes utiles

```bash
# Voir tous les ressources
kubectl get all -n coach-vitrine

# Supprimer le déploiement
kubectl delete namespace coach-vitrine

# Redémarrer un service
kubectl rollout restart deployment/users-service -n coach-vitrine

# Mettre à l'échelle
kubectl scale deployment frontend --replicas=5 -n coach-vitrine

# Logs en temps réel
kubectl logs -f -l app=users-service -n coach-vitrine
```
