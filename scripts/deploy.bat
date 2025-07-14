@echo off
REM Script de déploiement Kubernetes pour Windows
echo Déploiement de l'application Coach Vitrine sur Kubernetes

REM Vérifier que kubectl est disponible
kubectl version >nul 2>&1
if %errorlevel% neq 0 (
    echo kubectl n'est pas installé ou n'est pas dans le PATH
    exit /b 1
)

REM Vérifier la connexion au cluster
echo Vérification de la connexion au cluster...
kubectl cluster-info
if %errorlevel% neq 0 (
    echo Impossible de se connecter au cluster Kubernetes
    exit /b 1
)

REM Créer les namespaces
echo Création des namespaces...
kubectl apply -f k8s\namespaces\namespaces.yaml

REM Créer les secrets
echo Création des secrets...
kubectl apply -f k8s\secrets\secrets.yaml

REM Créer les configmaps
echo Création des configmaps...
kubectl apply -f k8s\configmaps\configmaps.yaml

REM Créer les volumes
echo Création des volumes persistants...
kubectl apply -f k8s\volumes\postgres-volume.yaml

REM Attendre que le PVC soit bound
echo Attente que le PVC soit bound...
kubectl wait --for=condition=Bound pvc/postgres-pvc -n coach-vitrine --timeout=60s

REM Déployer PostgreSQL en premier
echo Déploiement de PostgreSQL...
kubectl apply -f k8s\deployments\postgres-deployment.yaml
kubectl apply -f k8s\services\services.yaml

REM Attendre que PostgreSQL soit prêt
echo Attente que PostgreSQL soit prêt...
kubectl wait --for=condition=Ready pod -l app=postgres -n coach-vitrine --timeout=300s

REM Déployer les services backend
echo Déploiement des services backend...
kubectl apply -f k8s\deployments\backend-deployments.yaml

REM Attendre que les services backend soient prêts
echo Attente que les services backend soient prêts...
kubectl wait --for=condition=Ready pod -l app=users-service -n coach-vitrine --timeout=300s
kubectl wait --for=condition=Ready pod -l app=posts-service -n coach-vitrine --timeout=300s

REM Déployer le frontend
echo Déploiement du frontend...
kubectl apply -f k8s\deployments\frontend-deployment.yaml

REM Attendre que le frontend soit prêt
echo Attente que le frontend soit prêt...
kubectl wait --for=condition=Ready pod -l app=frontend -n coach-vitrine --timeout=300s

REM Déployer l'ingress
echo Configuration de l'ingress...
kubectl apply -f k8s\ingress\ingress.yaml

echo Déploiement terminé avec succès!
echo.
echo État des pods:
kubectl get pods -n coach-vitrine
echo.
echo Services:
kubectl get services -n coach-vitrine
echo.
echo Ingress:
kubectl get ingress -n coach-vitrine
echo.
echo Application accessible sur: http://app.local
echo N'oubliez pas d'ajouter '127.0.0.1 app.local' à votre fichier C:\Windows\System32\drivers\etc\hosts
